#!/usr/bin/env zx
$.verbose = false

const MAX_TEXT_LENGTH = 100

const [ ,...args ] = argv._
console.log(argv)

const ignoreList = await $`git status --ignored --short  | grep "^\!\!" | cut -d' ' -f 2`

const excludeArgs = ignoreList.stdout.trim().split(/\n/).map(ignore =>
  // BSD grep is last slash
  ignore.endsWith('/') ? `--exclude-dir=${ignore.slice(0, -1)}` : `--exclude=${ignore}`
)
excludeArgs.push('--exclude-dir=.git')
excludeArgs.push('--exclude=yarn.lock')
excludeArgs.push('--exclude=package-lock.json')

const result = await $`grep ${excludeArgs} -ir ${args}`

const cuttedResult = result.stdout.trim().split(/\n/).reduce((all, current) => {
  const str = (current.length > MAX_TEXT_LENGTH) ? current.substr(0, MAX_TEXT_LENGTH) : current
  return all + str + '\n'
}, '')
console.log(cuttedResult)
