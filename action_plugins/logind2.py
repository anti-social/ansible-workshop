import os.path

from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):
    LINGER_PATH = '/var/lib/systemd/linger'

    def run(self, tmp=None, task_vars=None):
        result = super().run(tmp, task_vars)

        user = self._task.args.get('user', None)
        errors = []
        if not user:
            errors.append('user is required')
        linger = self._task.args.get('linger', None)
        if not linger:
            errors.append('linger is required')

        if errors:
            result['msg'] = ', '.join(errors)
            result['failed'] = True
            return result

        user_linger_path = os.path.join(self.LINGER_PATH, user)
        result['linger_path'] = user_linger_path
        user_linger_stat = self._execute_module(
            module_name='ansible.builtin.stat',
            module_args={'path': user_linger_path},
            task_vars=task_vars,
            tmp=tmp,
        )
        if user_linger_stat['stat']['exists']:
            return result

        enable_linger_result = self._execute_module(
            module_name='ansible.builtin.command',
            module_args={'argv': ['/usr/bin/loginctl', 'enable-linger', user]},
            task_vars=task_vars,
            tmp=tmp,
        )
        if enable_linger_result.get('failed'):
            result['msg'] = enable_linger_result['msg']
            result['failed'] = True
            return result

        result['changed'] = True

        return result
