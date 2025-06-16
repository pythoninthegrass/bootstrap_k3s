# TODO

* ~~Setup local overprovisioned ubuntu vm (e.g., orbstack)~~
* Terraform
  * ~~Deploy to local ubuntu vm~~
  * ~~Deploy to rack ubuntu server~~
* Ansible
  * Refactor
    * Update inventory.yml and vault.yml
      * `scripts/inventory.sh`
    * Test
      * main.yml
      * test.yml
      * uninstall.yml
    * Move more vars to `group_vars`
    * Continue to split tasks into smaller files
  * Write tests w/molecule
  * Debug `ansible-navigator` ssh connection on macos
* Add task runners
