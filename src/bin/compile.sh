#!/usr/bin/env bash

function ublock_file() {
  metadata="${1}"
  input="${2}"
  output="${3}"

  echo -n "${output}"
  cat "${metadata}" > "${output}"
  echo -n "..."
  awk -v OFS='\n' '{
  n = split($0, fields, ",");
  if (n >= 3) print "! " fields[2] ": " fields[3];
  print "duckduckgo.com##[data-domain*=\"" fields[1] "\"]";
  print "google.*##.g:has(a[href*=\"" fields[1] "\"])";
  print fields[1]
}' "${input}" >> "${output}"
  echo -n "uBlock..."
}

function leechblock_file() {
  metadata="${1}"
  input="${2}"
  output="${3/.txt/.leechblock.txt}"

  awk -v OFS='\n' '{
  n = split($0, fields, ",");
  print fields[1]
}' "${input}" >> "${output}"
  echo -n "Leechblock..."
}

# Get root directory of repo
root="$(git rev-parse --show-cdup)"
srcpath="${root}src/lists/"
dstpath="${root}dist/"

git rm -rf "${dstpath}" 2>/dev/null
rm -r ${dstpath}*.txt 2>/dev/null

mkdir -p "${dstpath}"

for i in $(ls ${srcpath}*.metadata.txt); do
  srcfile="${i/.metadata/}"
  basename=$(basename -- "${srcfile}")
  dstfile="${dstpath}${basename}"

  ublock_file "${i}" "${srcfile}" "${dstfile}"
  leechblock_file "${i}" "${srcfile}" "${dstfile}"
  echo "Done!"
done

exec git add -v "${dstpath}"
