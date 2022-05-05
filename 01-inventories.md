# Ansible inventories

First of all we should create `ansible.cfg`.

Then an ansible inventory file `inventories/all.yaml` which describes all our servers.

Now we are able to run our first ansible command:

```bash
ansible all -m ping
```

Here an output we should see:

```
vm-02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
vm-01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

See ansible facts:

```bash
ansible all -m debug -a var=ansible_facts
```

Or other useful variables:

```bash
ansible all -m debug -a var=groups
ansible all -m debug -a var=hostvars
```
