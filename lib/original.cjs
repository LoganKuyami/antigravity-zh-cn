'use strict';
const fs=require('fs'),path=require('path');
const {parseArchive,sha256}=require('./asar.cjs');
function findOriginal(resources,specs,projectRoot){
 const live=fs.readFileSync(path.join(resources,'app.asar'));
 const pkg=JSON.parse(parseArchive(live).get('package.json').toString());
 const spec=specs.find(s=>s.version===pkg.version);
 if(pkg.name!=='antigravity'||!spec)throw Error('Unsupported installed application version: '+pkg.version);
 const candidates=[path.join(resources,'app.asar'),path.join(resources,'app.asar.original_backup'),path.join(projectRoot,'.local-build/payload/app.english.asar')];
 for(const name of fs.readdirSync(resources)){if(name.startsWith('zh-localization')){candidates.push(path.join(resources,name,'.local-build/payload/app.english.asar'),path.join(resources,name,'payload/app.english.asar'));}}
 const backups=path.join(resources,'zh-backups');if(fs.existsSync(backups))for(const name of fs.readdirSync(backups).sort().reverse())candidates.push(path.join(backups,name,'app.asar'));
 for(const name of candidates){if(!fs.existsSync(name))continue;const original=fs.readFileSync(name);if(sha256(original)===spec.asarSha256)return{original,spec};}
 throw Error('Matching original backup not found for installed version '+pkg.version+'. Restore the official installation first.');
}
module.exports={findOriginal};
