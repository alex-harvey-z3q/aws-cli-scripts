.PHONY: test
test:
	@bash shunit2/test_delete_bucket.sh
	@bash shunit2/test_manage_secrets.sh
	@bash shunit2/test_revoke_rules.sh
