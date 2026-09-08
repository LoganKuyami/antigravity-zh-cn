'use strict';
const vm=require('vm');
function replaceExact(s,from,to){const count=s.split(from).length-1;if(count!==1)throw Error('Native patch anchor mismatch: '+from.slice(0,80));return s.replace(from,to);}
function nativePatches(archive){const changes={};function edit(name,pairs){let s=archive.get(name).toString('utf8');for(const[from,to]of pairs)s=replaceExact(s,from,to);new vm.Script(s,{filename:name});changes[name]=s;}
edit('dist/languageServer.js',[["            '--enable_sidecars',","            '--enable_sidecars',\n            ...(fs.existsSync(path_1.default.join(process.resourcesPath, 'web_bundle')) ? ['--web_bundle_path', path_1.default.join(process.resourcesPath, 'web_bundle')] : []),"]]);
edit('dist/menu.js',[["label: 'New Window'","label: '新建窗口'"],["label: 'Docs'","label: '官方文档'"]]);
edit('dist/main.js',[["label: 'New Window'","label: '新建窗口'"],["label: 'No agents running'","label: '没有运行中的 Agent'"],["label: `Open ${electron_1.app.getName()}`","label: `打开 ${electron_1.app.getName()}`"],["label: 'Quit'","label: '退出'"],["buttons: ['Cancel', 'Quit']","buttons: ['取消', '退出']"],["title: 'Confirm Quit'","title: '确认退出'"],["message: 'Are you sure you want to quit?'","message: '确定要退出吗？'"],["detail: 'There may be agents or background tasks running.'","detail: '可能仍有 Agent 或后台任务正在运行。'"]]);
edit('dist/ipcHandlers.js',[["title: 'Open workspace'","title: '打开工作区'"],["title: 'Open workspaces'","title: '打开工作区'"]]);
edit('dist/updater.js',[["title: 'Check for Updates'","title: '检查更新'"],["message: 'No updates available'","message: '暂无可用更新'"],["buttons: ['OK']","buttons: ['确定']"]]);
let tray=archive.get('dist/tray.js').toString();const from="(count > 0 ? `${count}` : 'No') +\n                    ' agent' +\n                    (count === 1 ? '' : 's') +\n                    ' running'";tray=replaceExact(tray,from,"(count > 0 ? `${count} 个 Agent 正在运行` : '没有运行中的 Agent')");new vm.Script(tray);changes['dist/tray.js']=tray;
return changes;}
module.exports={nativePatches};
