#!/usr/bin/env zx
$.verbose = true

const [ , input, output ] = argv._

if (input && output) {
  if (input.includes('.png') || input.includes('.PNG')) {
    await $`vips pngsave ${input} ${output} --compression=9 --palette=true --strip=true`
    process.exit(1)
  }
  if (input.includes('.jpeg') || input.includes('.JPEG') || input.includes('.jpg') || input.includes('.JPG')) {
    await $`vips pngjpeg ${input} ${output} --strip=true --optimize-coding=true --interlace=true --optimize-scans --trellis_quant=true --quant_table=3`
    process.exit(1)
  }
}
console.error('invalid arguments')
process.exit(0)
