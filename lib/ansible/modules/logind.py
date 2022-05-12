#!/usr/bin/env python
import os

from ansible.module_utils.basic import AnsibleModule


LINGER_PATH = '/var/lib/systemd/linger'

LINGER_ENABLED = 'enabled'
LINGER_DISABLED = 'disabled'

def main():
    module = AnsibleModule(
        argument_spec=dict(
            user=dict(type='str', required=True),
            linger=dict(
                type='str', required=True,
                choices=[LINGER_ENABLED, LINGER_DISABLED]),
        ),
        supports_check_mode=True
    )

    result = dict(
        changed=False,
    )

    user = module.params['user']
    linger_state = module.params['linger']

    user_linger_path = os.path.join(LINGER_PATH, user)
    linger_exists = os.path.exists(user_linger_path)
    result['linger_path'] = user_linger_path
    result['linger_enabled'] = linger_exists
    if (
        linger_state == LINGER_ENABLED and linger_exists or
        linger_state == LINGER_DISABLED and not linger_exists
    ):
        module.exit_json(**result)

    result['changed'] = True

    if module.check_mode:
        module.exit_json(**result)

    loginctl_exe = module.get_bin_path('loginctl', True)

    if linger_state == LINGER_ENABLED:
        loginctl_cmd = 'enable-linger'
    elif linger_state == LINGER_DISABLED:
        loginctl_cmd = 'disable-linger'
    (rc, out, err) = module.run_command(
        '{} {} {}'.format(loginctl_exe, loginctl_cmd, user)
    )
    if rc != 0:
        module.fail_json(
            msg='failure {} when enabling linger {}'.format(rc, err)
        )

    module.exit_json(**result)


if __name__ == '__main__':
    main()
