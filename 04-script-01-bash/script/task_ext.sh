#!/bin/bash

# Шаблон для grep:
string_validator="\[[[:digit:]]*-[[:alpha:]]*-[[:digit:]]*-[[:alpha:]]*\] *"
# Максимальное количество символов
max_symbol_count=30

commit_format_validate(){
  tmp="$(grep -c "$string_validator" "$*")"
  if [[ "$tmp" -eq "0" ]]; then
    echo "Format error"
    return 1
  else
    return 0
  fi
}

commit_symbol_count_validate(){
  string_symbol_count="$(echo "$*" | wc -m)"
  #echo "symbols count: $string_symbol_count"
  if [[ "$string_symbol_count" -gt "$max_symbol_count" ]]; then
    echo "Long message (>30 symbols)"
    return 1
  else
    return 0
  fi
}

echo "Start commit checking.."
echo "Original format are --> $*"

if commit_format_validate "$1"; then
  if commit_symbol_count_validate "$1"; then
    echo "OK. You are beautiful!!"
    exit 0
  else
    exit 1
  fi
  else
    exit 1
fi

exit 0