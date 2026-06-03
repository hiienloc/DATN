const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    file = dir + '/' + file;
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) {
      results = results.concat(walk(file));
    } else {
      results.push(file);
    }
  });
  return results;
}

const files = walk('d:/freshfarm/src').filter(f => f.endsWith('.vue'));

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  const regex = /font-family:\s*[^;]+;?/gi;
  if (regex.test(content)) {
    content = content.replace(regex, '');
    fs.writeFileSync(file, content);
    console.log('Updated ' + file);
  }
});

console.log('Done!');
