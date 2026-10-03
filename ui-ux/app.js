'use strict';
const $ = selector => document.querySelector(selector);
const pages = [
  ['tree', '◎', 'Дерево', 'Дерево пассивных умений'],
  ['items', '◇', 'Снаряжение', 'Снаряжение'],
  ['skills', '✧', 'Умения', 'Умения и камни поддержки'],
  ['config', '☷', 'Условия боя', 'Условия боя'],
  ['calcs', '▤', 'Расчёты', 'Подробные расчёты'],
  ['compare', '⇄', 'Сравнение', 'Сравнение сборок'],
  ['party', '♧', 'Группа', 'Группа и приспешники'],
  ['notes', '≡', 'Заметки', 'Заметки и план развития'],
  ['library', '▦', 'Мои сборки', 'Библиотека сборок'],
];
const defaults = { page: 'tree', level: 90, theme: 'dark', set: 'Основной', enemy: 'Обычный противник', nodes: [0, 1, 2], equipment: {}, notes: 'Следующие шаги\n\n• Подобрать кольцо с сопротивлением хаосу.\n• Сравнить набор для боссов.\n• Проверить резервирование духа.', skills: [true, true, true], config: [false, true, false] };
function load() {
  try { return { ...defaults, ...JSON.parse(localStorage.getItem('pob-workshop') || '{}') }; }
  catch { return structuredClone(defaults); }
}
let state = load();
const history = [];
let toastTimer;
function toast(message) { $('#toast').textContent = message; $('#toast').classList.add('visible'); clearTimeout(toastTimer); toastTimer = setTimeout(() => $('#toast').classList.remove('visible'), 2800); }
function save() { try { localStorage.setItem('pob-workshop', JSON.stringify(state)); $('#save-state').textContent = 'Сохранено на устройстве'; } catch { $('#save-state').textContent = 'Хранилище недоступно'; } }
function change(callback, redraw = true) { history.push(structuredClone(state)); if (history.length > 40) history.shift(); callback(); save(); if (redraw) render(); }
function button(text, action, className = '') { const el = document.createElement('button'); el.textContent = text; el.className = className; el.addEventListener('click', action); return el; }
function openModal(title, content) { $('#modal-content').replaceChildren(); const h = document.createElement('h2'); h.textContent = title; $('#modal-content').append(h, content); $('#modal').showModal(); }
function go(page) { state.page = page; save(); render(); }
function render() {
  if (!pages.some(page => page[0] === state.page)) state.page = 'tree';
  document.body.classList.toggle('light', state.theme === 'light');
  $('#level').value = state.level;
  $('#build-set').value = state.set;
  $('#enemy').value = state.enemy;
  $('#navigation').replaceChildren(...pages.map(([id, icon, label]) => {
    const el = button('', () => go(id), state.page === id ? 'active' : '');
    el.innerHTML = `<span class="icon" aria-hidden="true">${icon}</span>${label}`;
    if (state.page === id) el.setAttribute('aria-current', 'page');
    return el;
  }));
  $('#page-title').textContent = pages.find(page => page[0] === state.page)[3];
  $('#workspace').replaceChildren();
  renderers[state.page]();
}
function html(markup) { $('#workspace').innerHTML = markup; }
const svgNS = 'http://www.w3.org/2000/svg';
const nodes = [{x:450,y:290,name:'Начало: Чародейка'}];
const edges = [];
for (let arm = 0; arm < 8; arm++) {
  let previous = 0;
  for (let step = 1; step <= 7; step++) {
    const angle = arm * Math.PI / 4 + Math.sin(step * .8) * .15;
    const radius = step * 34;
    const id = nodes.length;
    nodes.push({x:450 + Math.cos(angle) * radius * 1.5,y:290 + Math.sin(angle) * radius,name: step === 7 ? ['Проводник бури','Живая энергия','Поток маны','Сила стихий','Быстрая мысль','Стойкость','Чистая искра','Усиление'][arm] : `Малый узел ${id}`,major:step === 7});
    edges.push([previous,id]); previous=id;
  }
}
function tree() {
  html(`<div class="toolbar"><input id="tree-search" placeholder="Найти пассивное умение…" aria-label="Поиск узла"><span class="subtle" id="point-count"></span></div><div class="tree-stage"><svg viewBox="0 0 900 580" aria-label="Демонстрационное дерево пассивных умений"><g id="tree-map"></g></svg><div class="tree-controls"><button id="zoom-out" aria-label="Уменьшить">−</button><button id="zoom-in" aria-label="Увеличить">+</button><button id="reset-view" aria-label="Центрировать">⌖</button></div><div class="tree-caption"><span>Перетаскивайте поле · нажмите на узел</span><span>Схематичное дерево</span></div></div><div class="panel selection"><div><b id="node-name">Выберите пассивное умение</b><p id="node-detail">Изучайте дерево без потери контекста сборки.</p></div><button id="tree-report">Отчёт по узлам ↗</button></div>`);
  const map = $('#tree-map');
  const allocated = new Set(state.nodes);
  $('#point-count').textContent = `${Math.max(0,allocated.size - 1)} очков выбрано`;
  for (const [a,b] of edges) {
    const line = document.createElementNS(svgNS,'line');
    for (const [key,value] of Object.entries({x1:nodes[a].x,y1:nodes[a].y,x2:nodes[b].x,y2:nodes[b].y,class:allocated.has(a)&&allocated.has(b)?'edge allocated':'edge'})) line.setAttribute(key,value);
    map.append(line);
  }
  nodes.forEach((node,id) => {
    const g = document.createElementNS(svgNS,'g');
    g.setAttribute('class',`tree-node ${node.major?'major':''} ${allocated.has(id)?'selected':''}`);
    g.setAttribute('transform',`translate(${node.x} ${node.y})`); g.setAttribute('tabindex','0'); g.setAttribute('role','button'); g.setAttribute('aria-label',node.name); g.setAttribute('aria-pressed',allocated.has(id));
    g.innerHTML = `<circle r="${id===0?27:node.major?14:6}"/><text>${id===0?'✧':node.major?'◇':''}</text><title>${node.name}</title>`;
    const toggle = () => { if(id===0)return; change(() => { state.nodes = allocated.has(id) ? state.nodes.filter(n=>n!==id) : [...state.nodes,id]; }); $('#node-name').textContent=node.name; $('#node-detail').textContent='Выбор сохранён. Эффект на показатели появится после подключения расчётного движка.'; };
    g.addEventListener('click',toggle);g.addEventListener('keydown',event=>{if(event.key==='Enter'||event.key===' '){event.preventDefault();toggle();}});map.append(g);
  });
  let scale=1,x=0,y=0,drag=null;
  const transform=()=>map.setAttribute('transform',`translate(${450+x} ${290+y}) scale(${scale}) translate(-450 -290)`);
  const zoom = factor => {scale=Math.min(3,Math.max(.5,scale*factor));transform();};
  $('#zoom-in').onclick=()=>zoom(1.2);$('#zoom-out').onclick=()=>zoom(1/1.2);$('#reset-view').onclick=()=>{scale=1;x=0;y=0;transform();};
  const stage=$('.tree-stage');
  stage.addEventListener('pointerdown',e=>{if(e.target.closest('.tree-node,button'))return;drag={x:e.clientX,y:e.clientY};stage.setPointerCapture(e.pointerId);});
  stage.addEventListener('pointermove',e=>{if(!drag)return;const ratio=900/stage.clientWidth;x+=(e.clientX-drag.x)*ratio;y+=(e.clientY-drag.y)*ratio;drag={x:e.clientX,y:e.clientY};transform();});
  stage.addEventListener('pointerup',()=>drag=null);stage.addEventListener('pointercancel',()=>drag=null);
  stage.addEventListener('wheel',e=>{e.preventDefault();zoom(e.deltaY<0?1.1:1/1.1);},{passive:false});
  $('#tree-search').oninput=e=>{map.querySelectorAll('.tree-node').forEach((g,id)=>g.style.opacity=nodes[id].name.toLowerCase().includes(e.target.value.toLowerCase())?'1':'.2');};
  $('#tree-report').onclick=()=>toast('В полном приложении здесь будет рейтинг узлов из TreeTab.lua.');
}
const items = [
  {name:'Посох грозы',slot:'Оружие',icon:'⚚',mods:['+3 к уровню умений молнии','Увеличение урона чар на 82%','+46 к интеллекту']},
  {name:'Корона рассвета',slot:'Шлем',icon:'♜',mods:['Энергетический щит: 312','+84 к максимуму здоровья','+35% к сопротивлению холоду']},
  {name:'Кольцо тихой бури',slot:'Кольцо',icon:'◉',mods:['+120 к максимуму маны','+24% к сопротивлению хаосу','Увеличение скорости сотворения чар на 12%']},
  {name:'Одеяние странника',slot:'Броня',icon:'♢',mods:['Энергетический щит: 684','+96 к максимуму здоровья','+42% к сопротивлению огню']},
];
function equip(index) { const item=items[index];change(()=>state.equipment[item.slot]=index);toast(`${item.name}: помещён в слот «${item.slot}»`); }
function equipment() {
  html(`<div class="toolbar"><input id="item-search" placeholder="Найти предмет или модификатор…" aria-label="Поиск предметов"><button id="craft">+ Создать предмет</button></div><div class="slots">${['Оружие','Шлем','Броня','Перчатки','Сапоги','Кольцо'].map(slot=>`<div class="slot" data-slot="${slot}">${slot}<strong>${items[state.equipment[slot]]?.name||'Свободный слот'}</strong></div>`).join('')}</div><div class="toolbar"><h3>Библиотека предметов</h3><span class="subtle">Перетащите в слот или нажмите «Надеть»</span></div><div class="cards" id="item-list"></div>`);
  const list=$('#item-list');
  items.forEach((item,index)=>{const card=document.createElement('article');card.className='item-card';card.draggable=true;card.innerHTML=`<span class="item-symbol">${item.icon}</span><small>${item.slot} · пример редкого предмета</small><h3>${item.name}</h3>${item.mods.map(mod=>`<p>${mod}</p>`).join('')}`;card.append(button('Надеть',()=>equip(index)));card.ondragstart=e=>e.dataTransfer.setData('text/plain',String(index));list.append(card);});
  document.querySelectorAll('.slot').forEach(slot=>{slot.ondragover=e=>{e.preventDefault();slot.classList.add('dragover');};slot.ondragleave=()=>slot.classList.remove('dragover');slot.ondrop=e=>{e.preventDefault();slot.classList.remove('dragover');const raw=e.dataTransfer.getData('text/plain');if(!/^\d+$/.test(raw))return;const index=Number(raw);if(!items[index])return;if(items[index].slot!==slot.dataset.slot){toast('Этот предмет подходит для другого слота.');return;}equip(index);};});
  $('#item-search').oninput=e=>{[...list.children].forEach(card=>card.hidden=!card.textContent.toLowerCase().includes(e.target.value.toLowerCase()));};
  $('#craft').onclick=()=>{const div=document.createElement('div');div.innerHTML='<p>Макет редактора: в полной версии сюда переносится база модификаторов ItemsTab.lua.</p><label>База предмета <select><option>Посох</option><option>Кольцо</option><option>Одеяние</option></select></label><p>Префиксы, суффиксы, качество, осквернение и произвольные модификаторы сохраняются в проекте переноса.</p>';openModal('Мастерская предметов',div);};
}
function skills() {
  html(`<div class="toolbar"><h3>Набор умений · ${state.set}</h3><button id="add-skill">+ Добавить умение</button></div>${['Spark · Искра','Archmage · Архимаг','Conductivity · Проводимость'].map((name,i)=>`<div class="skill-row"><span class="gem">${['✧','◇','↯'][i]}</span><div class="grow"><b>${name}</b><small>${i===0?'Основное умение · 5 камней поддержки':'Поддерживающее умение'}</small></div><label>Уровень <input type="number" min="1" max="40" value="20" aria-label="Уровень ${name}"></label><input data-skill="${i}" type="checkbox" ${state.skills[i]?'checked':''} aria-label="Включить ${name}"></div>`).join('')}<div class="panel"><h3>Камни поддержки Искры</h3><p>Acceleration · Controlled Destruction · Arcane Tempo · Persistence · Considered Casting</p><p>Пример группы камней. Редактор связей, качество и эффекты предметов подключаются к SkillsTab.lua.</p></div>`);
  document.querySelectorAll('[data-skill]').forEach(el=>el.onchange=()=>change(()=>state.skills[el.dataset.skill]=el.checked,false));
  $('#add-skill').onclick=()=>toast('Выбор из полной базы камней предусмотрен на этапе подключения движка.');
}
function config() {
  html(`<div class="panel"><h2>Сценарий: ${state.enemy}</h2><p>Явные условия помогают сравнивать сборки честно.</p><div class="config-grid">${['Противник под действием шока','Вы недавно использовали умение','Максимум зарядов энергии'].map((label,i)=>`<label class="config-row">${label}<input type="checkbox" data-config="${i}" ${state.config[i]?'checked':''}></label>`).join('')}<label class="config-row">Уровень противника<input type="number" min="1" max="100" value="82"></label><label class="config-row">Эффект шока<select><option>Автоматически</option><option>Указать вручную</option></select></label></div><details><summary>Расширенные условия</summary><p>Полный перечень условий, пользовательские модификаторы и наборы настроек переносится из ConfigTab.lua без удаления параметров.</p></details></div>`);
  document.querySelectorAll('[data-config]').forEach(el=>el.onchange=()=>change(()=>state.config[el.dataset.config]=el.checked,false));
}
function calcs() {
  html('<div class="panel"><h2>Откуда берётся результат</h2><p>Демонстрация раскрываемого расчёта. Значения не получены из игрового движка.</p><table><thead><tr><th>Показатель</th><th>Значение</th><th>Источник</th></tr></thead><tbody><tr><td>Средний урон</td><td>8 120</td><td>Умение + модификаторы</td></tr><tr><td>Сотворений в секунду</td><td>5,24</td><td>Базовое время + скорость</td></tr><tr><td>Шанс критического удара</td><td>34,8%</td><td>База + увеличение</td></tr><tr><td>Множитель критического удара</td><td>280%</td><td>Дерево + снаряжение</td></tr></tbody></table><details open><summary>Раскрыть источники скорости сотворения</summary><p>Умение: базовое время · дерево: увеличение скорости · предметы: модификаторы · камни поддержки: множители.</p></details><details><summary>Защита, резервирование и приспешники</summary><p>Для каждого показателя предусматривается исходная разбивка CalcsTab.lua, включая подсказки, условия и неподдерживаемые модификаторы.</p></details></div>');
}
function compare() { html('<div class="panel"><div class="toolbar"><h2>Основной → Для боссов</h2><span class="pill">Пример сравнения</span></div><table><thead><tr><th>Показатель</th><th>Основной</th><th>Для боссов</th><th>Разница</th></tr></thead><tbody><tr><td>Урон в секунду</td><td>128 450</td><td>146 200</td><td class="positive">+13,8%</td></tr><tr><td>Энергетический щит</td><td>4 120</td><td>3 860</td><td class="warning">−6,3%</td></tr><tr><td>Сопротивление хаосу</td><td>32%</td><td>56%</td><td class="positive">+24 п.п.</td></tr></tbody></table><p>Одинаковые условия боя · видимые компромиссы · никакой скрытой подмены текущего набора.</p><details><summary>Предметы, дерево и поиск улучшений</summary><p>Панели соответствуют CompareTab.lua: сравнение сборок и предметов, отчёты по эффективности, покупка похожих предметов и торговые запросы.</p></details></div>'); }
function party() { html('<div class="panel"><h2>Поддержка рядом</h2><p>Отдельное пространство для участников группы и приспешников.</p><label class="config-row">Аура союзника: увеличение скорости<input type="checkbox"></label><label class="config-row">Проклятие союзника<input type="checkbox"></label><label class="config-row">Выбранный приспешник<select><option>Скелет-маг</option><option>Спектр</option></select></label><details><summary>Подробные параметры</summary><p>Список приспешников, параметры спектров, умения, эффекты группы и их расчёты должны использовать исходные данные PartyTab.lua и MinionListControl.lua.</p></details></div>'); }
function notes() { html('<div class="panel"><div class="toolbar"><h2>План следующей сессии</h2><span class="subtle">Автосохранение</span></div><textarea id="notes" aria-label="Заметки сборки"></textarea></div>');$('#notes').value=state.notes;$('#notes').oninput=e=>change(()=>state.notes=e.target.value,false); }
function library() { html('<div class="cards"><article class="panel"><div class="empty-symbol">✧</div><h2>Искра в темноте</h2><p>Чародейка · уровень '+state.level+'</p><p>Ваша текущая локальная демонстрационная сборка</p><button id="resume" class="primary">Продолжить сборку →</button></article><article class="panel"><div class="empty-symbol">⇄</div><h2>Перенести сборку</h2><p>Экспортируйте состояние прототипа в JSON и откройте его на другом устройстве.</p><button id="library-import">Импорт состояния</button></article></div>');$('#resume').onclick=()=>go('tree');$('#library-import').onclick=importState; }
const renderers = {tree,items:equipment,skills,config,calcs,compare,party,notes,library};
function importState() {
  const div=document.createElement('div'); const info=document.createElement('p');info.textContent='Импорт JSON этого прототипа. Коды PoB и персонажи аккаунта будут поддержаны при подключении исходного ImportTab.lua.';
  const area=document.createElement('textarea');area.setAttribute('aria-label','JSON состояния');area.placeholder='Вставьте экспортированное состояние';
  const error=document.createElement('p');error.setAttribute('role','alert');
  div.append(info,area,error,button('Импортировать',()=>{try{const data=JSON.parse(area.value);if(data.format!=='pob-ui-prototype-v1'||!data.state)throw Error('Это не экспорт прототипа.');const s=data.state;if(!pages.some(p=>p[0]===s.page)||!Number.isInteger(s.level)||s.level<1||s.level>100||!['dark','light'].includes(s.theme)||!Array.isArray(s.nodes)||s.nodes.some(n=>!Number.isInteger(n)||n<0||n>=nodes.length)||typeof s.notes!=='string'||!Array.isArray(s.skills)||s.skills.length!==3||s.skills.some(v=>typeof v!=='boolean')||!Array.isArray(s.config)||s.config.length!==3||s.config.some(v=>typeof v!=='boolean')||!s.equipment||Object.entries(s.equipment).some(([slot,i])=>!items[i]||items[i].slot!==slot)||!['Основной','Для боссов','Для карт'].includes(s.set)||!['Обычный противник','Босс'].includes(s.enemy))throw Error('Некорректное состояние.');change(()=>state={...defaults,...s});$('#modal').close();toast('Состояние прототипа импортировано.');}catch(e){error.textContent='Не удалось импортировать: '+e.message;}},'primary'));
  openModal('Импорт состояния',div);
}
$('#import').onclick=importState;
$('#export').onclick=()=>{const blob=new Blob([JSON.stringify({format:'pob-ui-prototype-v1',state},null,2)],{type:'application/json'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='pob-workshop.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);toast('Состояние прототипа экспортировано.');};
$('#theme').onclick=()=>change(()=>state.theme=state.theme==='dark'?'light':'dark');
$('#level').onchange=e=>change(()=>state.level=Math.min(100,Math.max(1,Number(e.target.value)||1)));
$('#build-set').onchange=e=>change(()=>state.set=e.target.value);
$('#enemy').onchange=e=>change(()=>state.enemy=e.target.value);
$('#undo').onclick=()=>{if(!history.length){toast('Пока нечего отменять.');return;}state=history.pop();save();render();toast('Последнее изменение отменено.');};
$('#open-calcs').onclick=()=>go('calcs');
$('#command').onclick=()=>{const div=document.createElement('div');const input=document.createElement('input');input.placeholder='Куда перейти?';input.setAttribute('aria-label','Поиск раздела');input.style.width='100%';const results=document.createElement('div');results.className='results';const update=()=>results.replaceChildren(...pages.filter(p=>p[3].toLowerCase().includes(input.value.toLowerCase())).map(p=>button(p[3],()=>{$('#modal').close();go(p[0]);})));input.oninput=update;div.append(input,results);update();openModal('Быстрый переход',div);input.focus();};
document.addEventListener('keydown',e=>{if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){e.preventDefault();if(!$('#modal').open)$('#command').click();}});
render();
