SHELL=/bin/bash

all:

prepare-dirs:
	mkdir -v -p secrets/{postgres,camunda,catalogueapi,flyway,profile,mailer,messenger}
	mkdir -v -p logs/{catalogueapi,api-gateway,bpm-engine,bpm-worker,profile,pid,mailer,messenger}

generate-signing-keys: .generate-signing-key-for-JWT .generate-signing-key-for-contracts

generate-secret-for-Flyway:
	cat secrets/postgres/opertusmundi-password | xargs printf "flyway.password=%s" > secrets/flyway/secret.conf
	chmod 0640 secrets/flyway/secret.conf

fix-ownership-of-data-volumes: .fix-ownership-of-data-volume-for-profile-output

.generate-signing-key-for-JWT:
	test -f secrets/key || { \
	  dd if=/dev/urandom bs=1 count=18 | base64 -w 0 > secrets/key; }
	chmod 0640 secrets/key

.generate-signing-key-for-contracts:
	test -f secrets/signatory-keystore-password || { \
	  dd if=/dev/urandom bs=1 count=9 | base64 -w 0 > secrets/signatory-keystore-password; }
	chmod 0640 secrets/signatory-keystore-password
	test -f secrets/signatory-keystore || { \
	   keytool -genkeypair -keystore secrets/signatory-keystore \
	     -keyalg RSA \
	     -storetype PKCS12 \
	     -alias 1 \
	     -storepass:file secrets/signatory-keystore-password \
		 -dname 'CN=example.com,OU=devel,O=Example Domain,L=Athens,ST=Greece,C=GR'; }

.fix-ownership-of-data-volume-for-profile-output:
	docker-compose run --rm -u0 --no-deps -- profile chown 1000:1000 output

database-migrate:
	docker-compose run --rm flyway migrate

database-info:
	docker-compose run --rm flyway info

elastic_setup_dir := cli/src/main/resources/elastic
elastic_url := http://localhost:30200

elastic-setup: \
  .elastic-setup-pipeline-auto_timestamp_pipeline \
  .elastic-setup-index-assets .elastic-setup-index-assets_view .elastic-setup-index-assets_view_aggregate \
  .elastic-setup-transform-assets_view_transform

.elastic-setup-index-%:
	# Create index
	ls -1 -v $(elastic_setup_dir)/$(*)_index/V*settings.json | tail -n 1 | xargs cat |\
	  jq -M '. + {index: {number_of_shards: 1, number_of_replicas: 0}} | {settings: .}' |\
	  curl -s -XPUT $(elastic_url)/$(*) -H content-type:application/json --data-binary @- \
	&& echo
	# Define mappings for fields
	ls -1 -v $(elastic_setup_dir)/$(*)_index/V*mappings.json | tail -n 1 | xargs cat |\
	  curl -s -XPUT $(elastic_url)/$(*)/_mappings -H content-type:application/json --data-binary @- \
	&& echo \
	&& touch $(@)

.elastic-setup-pipeline-%:
	ls -1 -v $(elastic_setup_dir)/$(*)/V*settings.json | tail -n 1 | xargs cat |\
	  curl -s -XPUT $(elastic_url)/_ingest/pipeline/$(*) -H content-type:application/json --data-binary @- \
	&& echo \
	&& touch $(@)

.elastic-setup-transform-%:
	ls -1 -v $(elastic_setup_dir)/$(*)/V*settings.json | tail -n 1 | xargs cat |\
	  curl -s -XPUT $(elastic_url)/_transform/$(*) -H content-type:application/json --data-binary @- \
	&& echo
	curl -s -XPOST $(elastic_url)/_transform/$(*)/_start \
	&& echo \
	&& touch $(@)
	
