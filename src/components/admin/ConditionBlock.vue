<template>
  <node-view-wrapper class="condition-node">
    <div class="condition-card">
      <div class="card-header" contenteditable="false">
        <strong>Bloc de Décision (Condition)</strong>
      </div>
      
      <div class="card-body" contenteditable="false">
        <div class="form-group">
          <label>Question ou Condition :</label>
          <input 
            type="text" 
            v-model="question" 
            @input="updateAttributes" 
            placeholder="Ex: Le client est-il premium ?"
            class="input-field"
          />
        </div>

        <div class="branches">
          <div class="branch oui-branch">
            <label class="branch-label">Si <strong>OUI</strong> aller vers :</label>
            <select v-model="ouiTarget" @change="updateAttributes" class="select-field">
              <option value="next">Étape suivante (défaut)</option>
              <option value="stop">Fin de procédure</option>
              <optgroup label="Sauter vers une étape :">
                <option v-for="step in availableSteps" :key="step.id" :value="step.id">
                  Aller à : {{ step.text }}
                </option>
              </optgroup>
              <option value="custom">Autre (texte libre)...</option>
            </select>
            <input 
              v-if="ouiTarget === 'custom'" 
              type="text" 
              v-model="ouiText" 
              @input="updateAttributes" 
              placeholder="Ex: Contacter le manager"
              class="input-field mt-2"
            />
          </div>

          <div class="branch non-branch">
            <label class="branch-label">Si <strong>NON</strong> aller vers :</label>
            <select v-model="nonTarget" @change="updateAttributes" class="select-field">
              <option value="next">Étape suivante (défaut)</option>
              <option value="stop">Fin de procédure</option>
              <optgroup label="Sauter vers une étape :">
                <option v-for="step in availableSteps" :key="step.id" :value="step.id">
                  Aller à : {{ step.text }}
                </option>
              </optgroup>
              <option value="custom">Autre (texte libre)...</option>
            </select>
            <input 
              v-if="nonTarget === 'custom'" 
              type="text" 
              v-model="nonText" 
              @input="updateAttributes" 
              placeholder="Ex: Refuser la demande"
              class="input-field mt-2"
            />
          </div>
        </div>
      </div>
    </div>
  </node-view-wrapper>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { nodeViewProps, NodeViewWrapper } from '@tiptap/vue-3';

const props = defineProps(nodeViewProps);

const question = ref('');
const ouiTarget = ref('next');
const ouiText = ref('');
const nonTarget = ref('stop');
const nonText = ref('');

onMounted(() => {
  question.value = props.node.attrs.question || '';
  ouiTarget.value = props.node.attrs.ouiTarget || 'next';
  ouiText.value = props.node.attrs.ouiText || '';
  nonTarget.value = props.node.attrs.nonTarget || 'stop';
  nonText.value = props.node.attrs.nonText || '';
});

// Watch for external changes (like undo/redo)
watch(() => props.node.attrs, (newAttrs) => {
  if (newAttrs.question !== question.value) question.value = newAttrs.question;
  if (newAttrs.ouiTarget !== ouiTarget.value) ouiTarget.value = newAttrs.ouiTarget;
  if (newAttrs.ouiText !== ouiText.value) ouiText.value = newAttrs.ouiText;
  if (newAttrs.nonTarget !== nonTarget.value) nonTarget.value = newAttrs.nonTarget;
  if (newAttrs.nonText !== nonText.value) nonText.value = newAttrs.nonText;
}, { deep: true });

const updateAttributes = () => {
  props.updateAttributes({
    question: question.value,
    ouiTarget: ouiTarget.value,
    ouiText: ouiText.value,
    nonTarget: nonTarget.value,
    nonText: nonText.value,
  });
};

const availableSteps = computed(() => {
  const steps = [];
  if (!props.editor) return steps;
  
  const doc = props.editor.state.doc;
  doc.descendants((node, pos) => {
    if (node.type.name === 'heading' && node.attrs.level === 2) {
      steps.push({
        id: `step-${pos}`, // We use node position or text as an ID
        text: node.textContent,
        pos: pos
      });
    }
  });
  
  // We'll just use the exact text as the ID/value for simplicity of matching later
  return steps.map(s => ({ id: s.text, text: s.text }));
});

</script>

<style scoped>
.condition-node {
  margin: 1.5rem 0;
}

.condition-card {
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  background-color: #f8fafc;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.card-header {
  background-color: #475569;
  color: white;
  padding: 0.5rem 1rem;
  font-size: 0.95rem;
  font-weight: 600;
  display: flex;
  align-items: center;
}

.card-body {
  padding: 1rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-weight: 600;
  color: #334155;
  margin-bottom: 0.35rem;
  font-size: 0.95rem;
}

.input-field, .select-field {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  background: white;
  font-family: inherit;
  font-size: 0.95rem;
  color: #1e293b;
}

.input-field:focus, .select-field:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
}

.branches {
  display: flex;
  gap: 1rem;
  flex-direction: column;
}

@media (min-width: 600px) {
  .branches {
    flex-direction: row;
  }
}

.branch {
  flex: 1;
  background: white;
  padding: 0.85rem;
  border-radius: 6px;
  border: 1px solid #e2e8f0;
}

.branch-label {
  display: block;
  font-size: 0.88rem;
  color: #475569;
  margin-bottom: 0.4rem;
}

.mt-2 {
  margin-top: 0.5rem;
}
</style>
