.PHONY: install lint test docs

alex:
	@echo was here

install:
	@bash install.sh

lint:
	@shellcheck delete_bucket.sh
	@shellcheck manage_secrets.sh
	@shellcheck manage_parameters.sh
	@shellcheck revoke_rules.sh

test:
	@bash shunit2/test_delete_bucket.sh
	@bash shunit2/test_manage_secrets.sh
	@bash shunit2/test_manage_parameters.sh
	@bash shunit2/test_revoke_rules.sh

docs:
	ruby docs/_generate.rb
