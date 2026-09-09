<template>
  <div v-if="!authChecked" class="loading">Vérification de l'accès...</div>
  <div v-else class="editor-container">
    <div class="header">
      <div>
        <a :href="`${baseUrl}admin/dashboard`" class="back-link">← Retour</a>
        <h1>{{ isNew ? 'Nouvelle procédure' : 'Éditer la procédure' }}</h1>
      </div>
      <a :href="`${baseUrl}admin/guide`" target="_blank" class="btn btn-secondary guide-link">Guide d'utilisation ↗</a>
    </div>

    <form @submit.prevent="saveProcedure" class="card">
      <div class="form-group">
        <label>Titre de la procédure</label>
        <input type="text" v-model="form.title" required class="input-title" placeholder="Ex: Onboarding employé" />
      </div>

      <div class="form-group">
        <label>Catégorie</label>
        <select v-model="form.category_id" required>
          <option value="" disabled>Sélectionner une catégorie</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          <option value="NEW">+ Ajouter une catégorie...</option>
        </select>
        
        <div v-if="form.category_id === 'NEW'" class="new-category-input">
          <input type="text" v-model="newCategoryName" placeholder="Nom de la nouvelle catégorie" required />
        </div>
      </div>

      <div class="form-group">
        <div class="form-group-header">
          <label>Contenu de la procédure</label>
          <div class="view-mode-toggle">
            <span class="toggle-label">Disposition :</span>
            <button 
              type="button" 
              class="toggle-btn" 
              :class="{ active: viewMode === 'split' }" 
              @click="setViewMode('split')"
              title="Côte à côte (Éditeur à gauche, Diagramme à droite)"
            >
              Côte à côte
            </button>
            <button 
              type="button" 
              class="toggle-btn" 
              :class="{ active: viewMode === 'stacked' }" 
              @click="setViewMode('stacked')"
              title="À la suite (Diagramme sous l'éditeur)"
            >
              À la suite
            </button>
            <button 
              type="button" 
              class="toggle-btn" 
              :class="{ active: viewMode === 'editor' }" 
              @click="setViewMode('editor')"
              title="Masquer le diagramme et afficher uniquement l'éditeur"
            >
              Éditeur seul
            </button>
            <button 
              type="button" 
              class="toggle-btn" 
              :class="{ active: viewMode === 'diagram' }" 
              @click="setViewMode('diagram')"
              title="Masquer l'éditeur et afficher uniquement le panneau d'aperçu"
            >
              Aperçu seul
            </button>
          </div>
        </div>
        <div :class="['editor-split-container', `view-${viewMode}`]">
          <div class="editor-col" v-show="viewMode !== 'diagram'">
            <div class="editor-wrapper" v-if="editor">
              <div class="toolbar">
                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().undo().run()" title="Annuler">Annuler</button>
                  <button type="button" @click="editor.chain().focus().redo().run()" title="Refaire">Refaire</button>
                </div>

                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().toggleHeading({ level: 1 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }" title="Titre H1">H1</button>
                  <button type="button" @click="editor.chain().focus().toggleHeading({ level: 3 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 3 }) }" title="Titre H3">H3</button>
                  <button type="button" @click="editor.chain().focus().toggleHeading({ level: 4 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 4 }) }" title="Titre H4">H4</button>
                </div>

                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().toggleBold().run()" :class="{ 'is-active': editor.isActive('bold') }" title="Gras"><b>B</b></button>
                  <button type="button" @click="editor.chain().focus().toggleItalic().run()" :class="{ 'is-active': editor.isActive('italic') }" title="Italique"><i>I</i></button>
                  <button type="button" @click="editor.chain().focus().toggleUnderline().run()" :class="{ 'is-active': editor.isActive('underline') }" title="Souligné"><u>U</u></button>
                  <button type="button" @click="editor.chain().focus().toggleHighlight().run()" :class="{ 'is-active': editor.isActive('highlight') }" title="Surligner">Surligner</button>
                  <input type="color" @input="editor.chain().focus().setColor($event.target.value).run()" :value="editor.getAttributes('textStyle').color || '#000000'" title="Couleur de texte" class="color-picker" />
                </div>
                
                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().setTextAlign('left').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'left' }) }">Gauche</button>
                  <button type="button" @click="editor.chain().focus().setTextAlign('center').run()" :class="{ 'is-active': editor.isActive({ textAlign: 'center' }) }">Centré</button>
                  <button type="button" @click="setLink" :class="{ 'is-active': editor.isActive('link') }">Lien</button>
                  <button type="button" @click="triggerImageUpload">Image</button>
                  <input type="file" ref="fileInput" @change="handleImageUpload" accept="image/*" style="display: none" />
                  <button type="button" @click="editor.chain().focus().toggleBlockquote().run()" :class="{ 'is-active': editor.isActive('blockquote') }" title="Citation / Avertissement">Citation</button>
                </div>

                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run()" title="Insérer un nouveau tableau">Tableau</button>
                  <button type="button" @click="editor.chain().focus().toggleBulletList().run()" :class="{ 'is-active': editor.isActive('bulletList') }">• Liste</button>
                </div>

                <div class="toolbar-group table-actions" v-if="editor.isActive('table')">
                  <button type="button" @click="editor.chain().focus().addRowAfter().run()" title="Ajouter une ligne en dessous">+ Ligne</button>
                  <button type="button" @click="editor.chain().focus().deleteRow().run()" title="Supprimer la ligne actuelle">- Ligne</button>
                  <button type="button" @click="editor.chain().focus().addColumnAfter().run()" title="Ajouter une colonne à droite">+ Colonne</button>
                  <button type="button" @click="editor.chain().focus().deleteColumn().run()" title="Supprimer la colonne actuelle">- Colonne</button>
                  <button type="button" @click="editor.chain().focus().deleteTable().run()" class="danger-btn" title="Supprimer le tableau complet">Supprimer tableau</button>
                </div>

                <div class="toolbar-group">
                  <button type="button" @click="editor.chain().focus().toggleHeading({ level: 2 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }" title="Définir comme Étape" class="step-btn">
                    Étape (H2)
                  </button>
                  <button type="button" @click="addConditionBlock" class="condition-btn">
                    Condition (Si/Sinon)
                  </button>
                </div>
              </div>
              <editor-content :editor="editor" class="tiptap-content" />
            </div>
            <small class="help-text">Utilisez le bouton <strong>"Étape (H2)"</strong> pour structurer votre procédure. Les conditions interactives s'ajouteront automatiquement au diagramme.</small>
          </div>

          <div class="visualizer-col" v-show="viewMode !== 'editor'">
            <div class="visualizer-card">
              <div class="visualizer-header">
                <div class="panel-tabs">
                  <button 
                    type="button" 
                    class="panel-tab-btn" 
                    :class="{ active: previewTab === 'diagram' }" 
                    @click="previewTab = 'diagram'"
                  >
                    Diagramme
                  </button>
                  <button 
                    type="button" 
                    class="panel-tab-btn" 
                    :class="{ active: previewTab === 'procedure' }" 
                    @click="previewTab = 'procedure'"
                  >
                    Aperçu Résultat
                  </button>
                </div>
              </div>
              <div class="visualizer-body">
                <div v-show="previewTab === 'diagram'">
                  <Mermaid :chartText="liveMermaidChart" />
                </div>
                <div v-show="previewTab === 'procedure'" class="procedure-result-preview">
                  <div class="proc-preview-card">
                    <h2 class="proc-preview-title">{{ form.title || 'Titre de la procédure' }}</h2>
                    <div class="procedure-preview-content" v-html="form.content || '<p><em>Saisissez du contenu pour voir l\'aperçu...</em></p>'"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn" :disabled="saving">
          {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
        </button>
        <span v-if="successMsg" class="success-msg">{{ successMsg }}</span>
        <span v-if="errorMsg" class="error-msg">{{ errorMsg }}</span>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, markRaw } from 'vue';
import { supabase } from '../../lib/supabase';
import { useEditor, EditorContent, VueNodeViewRenderer } from '@tiptap/vue-3';
import { Node, mergeAttributes } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import { Image } from '@tiptap/extension-image';
import { Link } from '@tiptap/extension-link';
import { Underline } from '@tiptap/extension-underline';
import { TextAlign } from '@tiptap/extension-text-align';
import { Color } from '@tiptap/extension-color';
import { TextStyle } from '@tiptap/extension-text-style';
import { Highlight } from '@tiptap/extension-highlight';
import { Table } from '@tiptap/extension-table';
import { TableRow } from '@tiptap/extension-table-row';
import { TableCell } from '@tiptap/extension-table-cell';
import { TableHeader } from '@tiptap/extension-table-header';

import Mermaid from '../Mermaid.vue';
import ConditionBlockVue from './ConditionBlock.vue';

const baseUrl = import.meta.env.BASE_URL;
const liveMermaidChart = ref('');
let diagramUpdateTimer = null;

const updateLiveDiagram = () => {
  if (diagramUpdateTimer) clearTimeout(diagramUpdateTimer);
  diagramUpdateTimer = setTimeout(() => {
    const { mermaid } = extractStepsAndMermaid();
    liveMermaidChart.value = mermaid;
  }, 300);
};

const ConditionExtension = Node.create({
  name: 'conditionBlock',
  group: 'block',
  atom: true, // It's an un-editable block from Tiptap's perspective
  
  addAttributes() {
    return {
      question: { default: '' },
      ouiTarget: { default: 'next' },
      ouiText: { default: '' },
      nonTarget: { default: 'stop' },
      nonText: { default: '' }
    }
  },
  
  parseHTML() {
    return [{ tag: 'div[data-type="conditionBlock"]' }]
  },
  
  renderHTML({ node, HTMLAttributes }) {
    const { question, ouiTarget, ouiText, nonTarget, nonText } = node.attrs;

    const renderTarget = (target, text) => {
      if (target === 'next') return "Étape suivante";
      if (target === 'stop') return "Fin de la procédure";
      if (target === 'custom') return text || "Action spécifique";
      return `Étape : ${target}`; // It's a specific step jump
    };

    return [
      'div', 
      mergeAttributes(HTMLAttributes, { 'data-type': 'conditionBlock', class: 'condition-block' }),
      ['p', {}, ['strong', {}, `Condition : ${question || '...'}`]],
      ['ul', {},
        ['li', {}, ['strong', {}, 'Si OUI : '], renderTarget(ouiTarget, ouiText)],
        ['li', {}, ['strong', {}, 'Si NON : '], renderTarget(nonTarget, nonText)]
      ]
    ];
  },
  
  addNodeView() {
    return VueNodeViewRenderer(ConditionBlockVue)
  }
});

const authChecked = ref(false);
const isNew = ref(true);
const saving = ref(false);
const successMsg = ref('');
const errorMsg = ref('');
const viewMode = ref('split');
const previewTab = ref('diagram');

const setViewMode = (mode) => {
  viewMode.value = mode;
  if (typeof window !== 'undefined') {
    localStorage.setItem('editor_view_mode', mode);
  }
};

const categories = ref([]);
const newCategoryName = ref('');
const fileInput = ref(null);
const form = ref({
  id: null,
  title: '',
  category_id: '',
  content: '',
  mermaid_chart: ''
});

const editor = useEditor({
  content: form.value.content,
  extensions: [
    StarterKit,
    Image,
    Underline,
    Color,
    TextStyle,
    Highlight,
    Table.configure({ resizable: true }),
    TableRow,
    TableHeader,
    TableCell,
    Link.configure({ openOnClick: false }),
    TextAlign.configure({ types: ['heading', 'paragraph'] }),
    ConditionExtension
  ],
  onUpdate: ({ editor }) => {
    form.value.content = editor.getHTML();
    updateLiveDiagram();
  }
});

onBeforeUnmount(() => {
  if (editor.value) {
    editor.value.destroy();
  }
});

const setLink = () => {
  const previousUrl = editor.value.getAttributes('link').href;
  const url = window.prompt('URL du lien :', previousUrl);
  if (url === null) return;
  if (url === '') {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run();
    return;
  }
  editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
};

const triggerImageUpload = () => {
  if (fileInput.value) {
    fileInput.value.click();
  }
};

const handleImageUpload = (event) => {
  const file = event.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (e) => {
    const base64 = e.target.result;
    editor.value.chain().focus().setImage({ src: base64 }).run();
  };
  reader.readAsDataURL(file);
  event.target.value = ''; // reset
};

const addConditionBlock = () => {
  editor.value.commands.insertContent({
    type: 'conditionBlock',
    attrs: {
      question: '',
      ouiTarget: 'next',
      ouiText: '',
      nonTarget: 'stop',
      nonText: ''
    }
  });
};

onMounted(async () => {
  if (typeof window !== 'undefined') {
    const savedMode = localStorage.getItem('editor_view_mode');
    if (savedMode) viewMode.value = savedMode;
  }

  if (supabase.supabaseUrl !== 'https://placeholder.supabase.co') {
    const { data } = await supabase.auth.getSession();
    if (!data.session) {
      window.location.href = `${baseUrl}admin/login`;
      return;
    }
  }
  
  authChecked.value = true;
  await loadCategories();
  
  const urlParams = new URLSearchParams(window.location.search);
  const id = urlParams.get('id');
  if (id) {
    isNew.value = false;
    await loadProcedure(id);
  } else if (editor.value) {
    editor.value.commands.setContent('<p>Commencez à taper ici...</p><h2>Étape 1 : ...</h2><p>Détails de l\'étape 1</p>');
    updateLiveDiagram();
  }
});

const loadCategories = async () => {
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    categories.value = [{ id: '1', name: 'Ressources Humaines' }];
    return;
  }
  const { data } = await supabase.from('categories').select('*');
  if (data) categories.value = data;
};

const loadProcedure = async (id) => {
  if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
    const dummyData = {
      id: '101', title: 'Onboarding', category_id: '1',
      content: '<p>Test</p><h2>Etape 1</h2><p>Faire X</p>', mermaid_chart: 'graph TD\nA-->B'
    };
    form.value = { ...dummyData };
    if (editor.value) {
      editor.value.commands.setContent(dummyData.content);
      updateLiveDiagram();
    }
    return;
  }

  const { data } = await supabase.from('procedures').select('*').eq('id', id).single();
  if (data) {
    form.value = { ...data };
    if (editor.value) {
      editor.value.commands.setContent(data.content);
      updateLiveDiagram();
    }
  }
};

const extractStepsAndMermaid = (jsonContent) => {
  // If we have HTML, it's easier to parse from editor.getJSON()
  // But wait, our save function doesn't get JSON natively unless we call getJSON()
  // Let's use editor.getJSON() directly since we have the editor instance
  if (!editor.value) return { steps: [], mermaid: '' };
  
  const docJson = editor.value.getJSON();
  const steps = [];
  let mermaid = 'graph TD\n';
  let nodeIndex = 0;
  
  let currentStepId = null;
  let allNodes = [];

  // Flatten the top level nodes
  if (docJson && docJson.content) {
    for (const node of docJson.content) {
      if (node.type === 'heading' && node.attrs.level === 2) {
        let text = '';
        if (node.content) {
           text = node.content.map(n => n.text).join('').trim();
        }
        if (text) {
          const id = `N${nodeIndex++}`;
          steps.push(text);
          allNodes.push({ type: 'step', id, text, originalText: text });
        }
      } else if (node.type === 'conditionBlock') {
        const id = `N${nodeIndex++}`;
        allNodes.push({ type: 'condition', id, attrs: node.attrs });
      }
    }
  }

  // Find IDs based on exact text matching for jump targets
  const findStepIdByText = (text) => {
    const step = allNodes.find(n => n.type === 'step' && n.originalText === text);
    return step ? step.id : null;
  };

  const wrapMermaidText = (str, maxLineLen = 25) => {
    if (!str) return '';
    const clean = String(str).replace(/[\r\n]+/g, ' ').replace(/["\[\]{}()<>|]/g, '').trim();
    if (clean.length <= maxLineLen) return clean;

    const words = clean.split(/\s+/);
    const lines = [];
    let currentLine = '';

    for (const word of words) {
      if ((currentLine + ' ' + word).trim().length <= maxLineLen) {
        currentLine = (currentLine + ' ' + word).trim();
      } else {
        if (currentLine) lines.push(currentLine);
        currentLine = word;
      }
    }
    if (currentLine) lines.push(currentLine);

    return lines.join('<br/>');
  };

  // Build mermaid
  for (let i = 0; i < allNodes.length; i++) {
    const n = allNodes[i];
    
    if (n.type === 'step') {
      let safeText = wrapMermaidText(n.text, 25);
      mermaid += `  ${n.id}["${safeText}"]\n`;
      
      // If there is a next step, link to it (unless the PREVIOUS was a condition that stops/jumps)
      if (i > 0) {
        const prev = allNodes[i-1];
        if (prev.type === 'step') {
          mermaid += `  ${prev.id} --> ${n.id}\n`;
        }
      }
    } else if (n.type === 'condition') {
      let safeQuestion = wrapMermaidText(n.attrs.question || 'Condition?', 25);
      mermaid += `  ${n.id}{"${safeQuestion}"}\n`;
      
      if (i > 0) {
        const prev = allNodes[i-1];
        if (prev.type === 'step') {
          mermaid += `  ${prev.id} --> ${n.id}\n`;
        }
      }
      
      const processBranch = (target, customText, label) => {
        if (target === 'stop') {
          const endId = `N${nodeIndex++}`;
          mermaid += `  ${endId}(("Fin"))\n`;
          mermaid += `  ${n.id} -->|${label}| ${endId}\n`;
        } else if (target === 'next') {
          // Find next step in allNodes
          const nextNode = allNodes[i+1];
          if (nextNode) {
            mermaid += `  ${n.id} -->|${label}| ${nextNode.id}\n`;
          }
        } else if (target === 'custom') {
          const customId = `N${nodeIndex++}`;
          let safeCustom = wrapMermaidText(customText || 'Action', 20);
          mermaid += `  ${customId}["${safeCustom}"]\n`;
          mermaid += `  ${n.id} -->|${label}| ${customId}\n`;
        } else {
          // target is a jump step ID (exact text)
          const targetNodeId = findStepIdByText(target);
          if (targetNodeId) {
            mermaid += `  ${n.id} -->|${label}| ${targetNodeId}\n`;
          } else {
             // Fallback
             const customId = `N${nodeIndex++}`;
             let safeTarget = wrapMermaidText(target, 20);
             mermaid += `  ${customId}["Aller vers: ${safeTarget}"]\n`;
             mermaid += `  ${n.id} -->|${label}| ${customId}\n`;
          }
        }
      };

      processBranch(n.attrs.ouiTarget, n.attrs.ouiText, 'Oui');
      processBranch(n.attrs.nonTarget, n.attrs.nonText, 'Non');
    }
  }

  if (mermaid === 'graph TD\n') mermaid = '';
  
  return { steps, mermaid };
};

const saveProcedure = async () => {
  saving.value = true;
  successMsg.value = '';
  errorMsg.value = '';

  try {
    if (supabase.supabaseUrl !== 'https://placeholder.supabase.co' && form.value.category_id === 'NEW') {
      const { data: newCat, error: catError } = await supabase
        .from('categories')
        .insert([{ name: newCategoryName.value }])
        .select()
        .single();
      
      if (catError) throw catError;
      form.value.category_id = newCat.id;
      categories.value.push(newCat);
    }

    // We pass editor JSON to get structured nodes easily
    const { steps, mermaid } = extractStepsAndMermaid();
    
    const payload = {
      title: form.value.title,
      category_id: form.value.category_id === 'NEW' ? '1' : form.value.category_id,
      content: form.value.content,
      mermaid_chart: mermaid || form.value.mermaid_chart,
      steps: steps,
      updated_at: new Date().toISOString()
    };

    if (supabase.supabaseUrl === 'https://placeholder.supabase.co') {
      setTimeout(() => {
        successMsg.value = 'Enregistré avec succès (Mock)';
        saving.value = false;
      }, 500);
      return;
    }

    if (isNew.value) {
      payload.version = '1.0';
      const { error } = await supabase.from('procedures').insert([payload]);
      if (error) throw error;
      window.location.href = `${baseUrl}admin/dashboard`;
    } else {
      const currentVersion = parseFloat(form.value.version || '1.0');
      payload.version = (currentVersion + 0.1).toFixed(1);
      
      const { error } = await supabase.from('procedures').update(payload).eq('id', form.value.id);
      if (error) throw error;
      
      successMsg.value = 'Modifications enregistrées ! Version passée à ' + payload.version;
    }
  } catch (e) {
    console.error(e);
    errorMsg.value = "Erreur lors de l'enregistrement.";
  } finally {
    saving.value = false;
  }
};
</script>

<style scoped>
.header {
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  flex-wrap: wrap;
  gap: 1rem;
}

.guide-link {
  font-size: 0.9rem;
  text-decoration: none;
}

.back-link {
  color: var(--text-muted);
  text-decoration: none;
  font-weight: 500;
  display: inline-block;
  margin-bottom: 1rem;
}

h1 {
  margin: 0;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--text-main);
}

.help-text {
  display: block;
  margin-top: 0.25rem;
  color: var(--text-muted);
  font-size: 0.8rem;
}

input, select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--border);
  border-radius: 6px;
  font-family: inherit;
  font-size: 1rem;
}

.new-category-input {
  margin-top: 0.5rem;
}

input:focus, select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.input-title {
  font-size: 1.25rem;
  font-weight: 600;
}

/* Tiptap Editor Styles */
.editor-wrapper {
  border: 1px solid var(--border);
  border-radius: 6px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  padding: 0.75rem;
  background: #f8fafc;
  border-bottom: 1px solid var(--border);
}

.toolbar-group {
  display: flex;
  gap: 0.25rem;
  border-right: 1px solid #cbd5e1;
  padding-right: 1rem;
  align-items: center;
}

.toolbar-group:last-child {
  border-right: none;
}

.toolbar button {
  padding: 0.35rem 0.6rem;
  background: white;
  border: 1px solid var(--border);
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.toolbar button:hover {
  background: #e2e8f0;
}

.toolbar button.is-active {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
}

.color-picker {
  height: 30px;
  width: 30px;
  padding: 0;
  border: none;
  cursor: pointer;
  border-radius: 4px;
}

.step-btn {
  font-weight: bold;
  color: #0369a1 !important;
}

.condition-btn {
  font-weight: bold;
  color: #d97706 !important;
  background-color: #fef3c7 !important;
  border-color: #fcd34d !important;
}

.tiptap-content {
  max-height: 80vh;
  overflow: auto;
  padding: 1.5rem;
  min-height: 400px;
  background: white;
  cursor: text;
}

.tiptap-content :deep(.ProseMirror) {
  min-height: 400px;
  outline: none;
}

.tiptap-content :deep(.ProseMirror p.is-editor-empty:first-child::before) {
  color: #adb5bd;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

.tiptap-content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 4px;
}

.tiptap-content :deep(h1) {
  font-size: 2rem;
  margin-top: 1.5rem;
  margin-bottom: 1rem;
  color: var(--text-main);
}

.tiptap-content :deep(h2) {
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--primary);
  margin-top: 1.5rem;
  margin-bottom: 1rem;
  color: var(--text-main);
}

.tiptap-content :deep(h3) {
  font-size: 1.3rem;
  margin-top: 1.25rem;
  margin-bottom: 0.75rem;
  color: var(--text-main);
}

.tiptap-content :deep(h4) {
  font-size: 1.1rem;
  margin-top: 1rem;
  margin-bottom: 0.5rem;
  color: var(--text-main);
}

.tiptap-content :deep(a) {
  color: var(--primary);
  text-decoration: underline;
  cursor: pointer;
}

.tiptap-content :deep(blockquote) {
  border-left: 4px solid #3b82f6;
  background-color: #eff6ff;
  margin: 1.5rem 0;
  padding: 1rem 1.25rem;
  border-radius: 0 6px 6px 0;
  color: #1e3a8a;
  font-style: italic;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

.tiptap-content :deep(blockquote p) {
  margin-bottom: 0.5rem;
  margin-top: 0;
}

.tiptap-content :deep(blockquote p:last-child) {
  margin-bottom: 0;
}

.tiptap-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
  margin: 1.5rem 0;
  border: 1px solid #cbd5e1;
}

.tiptap-content :deep(td),
.tiptap-content :deep(th) {
  min-width: 1em;
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  text-align: left;
  vertical-align: top;
  box-sizing: border-box;
  position: relative;
}

.tiptap-content :deep(th) {
  font-weight: 600;
  background-color: #f1f5f9;
  color: #0f172a;
}

.tiptap-content :deep(tr:nth-child(even)) {
  background-color: #f8fafc;
}

.tiptap-content :deep(.selectedCell:after) {
  z-index: 2;
  position: absolute;
  content: "";
  left: 0; right: 0; top: 0; bottom: 0;
  background: rgba(59, 130, 246, 0.15);
  pointer-events: none;
}

.form-actions {
  margin-top: 2rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border);
}

.success-msg {
  color: #10b981;
  font-weight: 500;
}

.error-msg {
  color: #ef4444;
  font-weight: 500;
}

.form-group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.form-group-header label {
  margin-bottom: 0;
}

.view-mode-toggle {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background: #f1f5f9;
  padding: 0.25rem;
  border-radius: 6px;
  border: 1px solid var(--border);
}

.toggle-label {
  font-size: 0.8rem;
  color: var(--text-muted);
  font-weight: 600;
  margin-right: 0.25rem;
  padding-left: 0.25rem;
}

.toggle-btn {
  padding: 0.3rem 0.65rem;
  border: none;
  background: transparent;
  border-radius: 4px;
  font-size: 0.85rem;
  cursor: pointer;
  color: var(--text-muted);
  font-weight: 500;
  transition: all 0.15s ease;
  display: flex;
  align-items: center;
  gap: 0.3rem;
}

.toggle-btn:hover {
  color: var(--text-main);
  background: rgba(255, 255, 255, 0.6);
}

.toggle-btn.active {
  background: white;
  color: var(--primary);
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.table-actions button {
  background: #f1f5f9;
  border-color: #cbd5e1;
  font-size: 0.85rem;
  font-weight: 500;
  color: #334155;
}

.table-actions button:hover {
  background: #e2e8f0;
}

.danger-btn {
  color: #ef4444 !important;
  background: #fef2f2 !important;
  border-color: #fca5a5 !important;
}

.danger-btn:hover {
  background: #fee2e2 !important;
}

/* Split View & Live Visualizer Styles */
.editor-split-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.editor-split-container.view-stacked {
  display: flex !important;
  flex-direction: column !important;
}

.editor-split-container.view-editor,
.editor-split-container.view-diagram {
  display: block !important;
}

.editor-split-container.view-editor .editor-col,
.editor-split-container.view-diagram .visualizer-col {
  width: 100% !important;
}

@media (min-width: 992px) {
  .editor-split-container.view-split {
    display: grid;
    grid-template-columns: 1fr 1fr;
    align-items: start;
  }

  .editor-split-container.view-split .visualizer-col {
    position: sticky;
    top: 1.5rem;
  }
}

.visualizer-card {
  border: 1px solid var(--border);
  border-radius: 8px;
  background: #f8fafc;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}

.visualizer-header {
  padding: 0.6rem 1rem;
  background: white;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
}

.panel-tabs {
  display: flex;
  background: #f1f5f9;
  padding: 0.2rem;
  border-radius: 6px;
  border: 1px solid var(--border);
  gap: 0.2rem;
}

.panel-tab-btn {
  padding: 0.25rem 0.6rem;
  border: none;
  background: transparent;
  border-radius: 4px;
  font-size: 0.85rem;
  cursor: pointer;
  color: var(--text-muted);
  font-weight: 500;
  transition: all 0.15s ease;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.panel-tab-btn:hover {
  color: var(--text-main);
  background: rgba(255, 255, 255, 0.6);
}

.panel-tab-btn.active {
  background: white;
  color: var(--primary);
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.badge-live {
  background: #dbeafe;
  color: #1d4ed8;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.2rem 0.5rem;
  border-radius: 9999px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.visualizer-body {
  padding: 1rem;
  background: white;
  min-height: 350px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
}

.procedure-result-preview {
  padding: 0.5rem;
}

.proc-preview-title {
  font-size: 1.5rem;
  color: var(--text-main);
  margin-top: 0;
  margin-bottom: 1.25rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--primary);
}

.procedure-preview-content {
  font-size: 1rem;
  line-height: 1.6;
  color: #334155;
}

.procedure-preview-content :deep(h2) {
  margin-top: 1.5rem;
  margin-bottom: 1rem;
  padding: 0.5rem 0.75rem;
  background-color: #f8fafc;
  border-left: 4px solid var(--primary);
  border-radius: 0 6px 6px 0;
  color: var(--text-main);
}

.procedure-preview-content :deep(.condition-block) {
  background-color: #f8fafc;
  border: 1px solid #cbd5e1;
  border-left: 4px solid #475569;
  padding: 1rem;
  margin: 1.25rem 0;
  border-radius: 0 6px 6px 0;
}

.procedure-preview-content :deep(.condition-block p) {
  margin-top: 0;
  color: #1e293b;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.procedure-preview-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5rem 0;
  border: 1px solid #cbd5e1;
}

.procedure-preview-content :deep(th),
.procedure-preview-content :deep(td) {
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  text-align: left;
  vertical-align: top;
}

.procedure-preview-content :deep(th) {
  background-color: #f1f5f9;
  color: #0f172a;
  font-weight: 600;
}

.procedure-preview-content :deep(tr:nth-child(even)) {
  background-color: #f8fafc;
}

.procedure-preview-content :deep(blockquote) {
  border-left: 4px solid #3b82f6;
  background-color: #f8fafc;
  margin: 1.25rem 0;
  padding: 0.75rem 1rem;
  border-radius: 0 6px 6px 0;
  color: #1e3a8a;
}

.visualizer-body :deep(.mermaid-container) {
  margin: 0;
  box-shadow: none;
  border: none;
  padding: 0;
}

.visualizer-body :deep(.mermaid-title) {
  display: none;
}
</style>
