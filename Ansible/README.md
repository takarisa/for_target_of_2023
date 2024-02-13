## ホスト追加時のhostsの追加方法

- `roles/hosts/files/hosts`に追加
- `inventories/close/inventry-gear-all.yml`に追加（必要があれば）

- プレイブック`playbook-etc-hosts`をローカルに実行する
```
ansible-playbook --inventory inventories/close/inventry-gear-all.yml \
                 --connection=local \　　　　
                 --limit localhost \
                 --ask-become-pass \
                 --check \
                 playbook-etc-hosts.yml
```
- プレイブック`playbook-etc-hosts.yml`を全サーバに実行する
```
ansible-playbook --inventory inventories/close/inventry-gear-all.yml \
                 --ask-become-pass \
                 --check \
                 playbook-etc-hosts.yml
```