const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'in_game_clothes_editor';
const panel = document.getElementById('panel');
const controls = document.getElementById('controls');
const presetsElement = document.getElementById('presets');
const modelElement = document.getElementById('model');
let appearance = {};
let components = [];
let models = [];
let selectedModel = 'male';
let presets = {};

function post(endpoint, body = {}) {
    return fetch(`https://${resource}/${endpoint}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
}

function preview() {
    post('preview', { model: selectedModel, appearance });
}

function renderModels() {
    modelElement.innerHTML = '';
    models.forEach((item) => {
        const option = document.createElement('option');
        option.value = item.key;
        option.textContent = item.label;
        option.selected = item.key === selectedModel;
        modelElement.appendChild(option);
    });
}

function renderControls() {
    controls.innerHTML = '';
    components.forEach((item) => {
        const value = appearance[item.key] || { value: 0, texture: 0 };
        const row = document.createElement('div');
        row.className = 'row';
        row.innerHTML = `<label>${item.label}</label><input class="value" type="range" min="${item.type === 'prop' ? -1 : 0}" max="200" value="${value.value}"><input class="texture" type="number" min="0" max="200" value="${value.texture}">`;
        const valueInput = row.querySelector('.value');
        const textureInput = row.querySelector('.texture');
        const update = () => {
            appearance[item.key] = { value: Number(valueInput.value), texture: Math.max(0, Number(textureInput.value) || 0) };
            preview();
        };
        valueInput.addEventListener('input', update);
        textureInput.addEventListener('input', update);
        controls.appendChild(row);
    });
}

function renderPresets() {
    presetsElement.innerHTML = '';
    Object.keys(presets).sort().forEach((name) => {
        const row = document.createElement('div');
        row.className = 'preset';
        row.innerHTML = `<span>${name}</span><span><button class="load">Load</button> <button class="remove">Delete</button></span>`;
        row.querySelector('.load').addEventListener('click', () => {
            const preset = presets[name];
            selectedModel = preset.model || 'male';
            appearance = JSON.parse(JSON.stringify(preset.appearance || preset));
            modelElement.value = selectedModel;
            renderControls();
            post('load', { name });
        });
        row.querySelector('.remove').addEventListener('click', () => post('delete', { name }));
        presetsElement.appendChild(row);
    });
}

modelElement.addEventListener('change', () => {
    selectedModel = modelElement.value;
    appearance = {};
    renderControls();
    preview();
});
document.getElementById('save').addEventListener('click', () => {
    const name = document.getElementById('preset-name').value.trim();
    if (name) post('save', { name, model: selectedModel, appearance });
});
document.getElementById('save-character').addEventListener('click', () => {
    post('savePlayerOutfit', { model: selectedModel, appearance });
});
document.getElementById('close').addEventListener('click', () => post('close'));
document.addEventListener('keydown', (event) => { if (event.key === 'Escape') post('close'); });

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'open') {
        appearance = data.appearance || {};
        components = data.components || [];
        models = data.models || [];
        selectedModel = data.model || 'male';
        renderModels();
        panel.classList.remove('hidden');
        renderControls();
    } else if (data.action === 'presets') {
        presets = data.presets || {};
        renderPresets();
    } else if (data.action === 'close') {
        panel.classList.add('hidden');
    }
});
