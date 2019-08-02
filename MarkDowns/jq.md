## with JSON format getting more & more popular, jq deserves a dedicated file
## here is content example json file

```json
{
"key1": ["value10","value11","value12"],
"key2": ["value20"],
"key3_with_sub": {
        "subkey1": ["subvalue10"],
        "subkey2": ["subvalue20","subvalue21"]
        }
}
```

### extract keys
```bash
[hbcheng@hdc-sc-perf02 ~]$ jq 'keys' test.json
[
  "key1",
  "key2",
  "key3_with_sub"
]
```

### extract values of a key
```bash
[hbcheng@hdc-sc-perf02 ~]$ jq '.key1' test.json
[
  "value10",
  "value11",
  "value12"
]

[hbcheng@hdc-sc-perf02 ~]$ jq '.key3_with_sub' test.json
{
  "subkey1": [
    "subvalue10"
  ],
  "subkey2": [
    "subvalue20",
    "subvalue21"
  ]
}

```
