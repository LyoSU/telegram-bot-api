# Fork delta

This fork adds a few read-only methods and hardening options on top of
[tdlib/telegram-bot-api](https://github.com/tdlib/telegram-bot-api). The branch
`custom` is rebased onto upstream `master` automatically every day; the whole
delta is always visible as `git diff upstream/master..custom`. Licensed under
the same Boost Software License 1.0 as upstream.

## Added methods

### getMessages

Fetch up to 50 messages of a chat by their identifiers.

| Parameter | Type | Required | Description |
|---|---|---|---|
| chat_id | Integer or String | Yes | Target chat |
| message_ids | Array of Integer | Yes | 1-50 message identifiers |

Returns an *Array of Message*. Messages that cannot be found are silently
omitted, so the result may be shorter than the request. `reply_to_message` is
included when the replied-to message is known to the server.

```bash
curl -s "http://localhost:8081/bot$TOKEN/getMessages" \
  -H 'content-type: application/json' \
  -d '{"chat_id": 123456, "message_ids": [10, 11, 12]}'
```

### getUserInfo

Returns a *User* known to the bot by its identifier, extended with
`emoji_status_custom_emoji_id` (String, optional) — the custom emoji id of the
user's premium emoji status.

| Parameter | Type | Required | Description |
|---|---|---|---|
| user_id | Integer | Yes | Target user |

```bash
curl -s "http://localhost:8081/bot$TOKEN/getUserInfo" \
  -H 'content-type: application/json' \
  -d '{"user_id": 123456}'
```

## Added options

| Option | Description |
|---|---|
| `--allowed-bot-ids=<ids>` | Comma-separated bot ids (or full tokens; only the numeric prefix is used). When set, requests for any other bot are rejected with 421. Protects a publicly exposed server from being used as an open proxy. |
| `--relative` | In `--local` mode, return `file_path` relative to the bot's working directory (`<dir>/<bot-token>/`) instead of an absolute path. Handy when files are served by a reverse-proxy sidecar; also avoids leaking server paths. |
| `--stats-hide-sensible-data` | Hide bot tokens and webhook URLs on the statistics page. |
| `--max-pending-updates=<n>` | Drop the oldest pending updates of a bot once its queue exceeds `n` (cleared down to ~90% of `n` per pass, same mechanism as `getUpdates` with a negative offset). Bounds the server's memory when a bot stops fetching updates. Defaults to the `TELEGRAM_MAX_PENDING_UPDATES` environment variable; disabled when neither is set. The hard upstream cap of 100000 still applies. Drops are visible as `dropped_update_count` on the statistics page and as warnings in the log. |
