import { useState } from 'react';

const THEME_LABELS = {
  crypto: '₿ crypto',
  expat: '🌍 expat life',
  work: '💼 work',
  casual: '☕ casual',
};

export default function QuestionCard({ question, onAnswer }) {
  const [selected, setSelected] = useState(null);

  function handleSelect(opt) {
    if (selected) return;
    setSelected(opt);
    setTimeout(() => onAnswer(opt), 180);
  }

  return (
    <div className="question-card">
      <div className="question-theme-tag">{THEME_LABELS[question.theme]}</div>

      <h2 className="question-text">{formatQuestion(question.question)}</h2>

      <div className="options-grid">
        {question.options.map((opt) => (
          <button
            key={opt}
            className={`option-btn ${selected === opt ? 'selected' : ''}`}
            onClick={() => handleSelect(opt)}
          >
            {opt}
          </button>
        ))}
      </div>
    </div>
  );
}

function formatQuestion(text) {
  // Highlight the blank (___) visually
  const parts = text.split('___');
  if (parts.length === 1) return text;
  return (
    <>
      {parts[0]}
      <span className="blank-marker">___</span>
      {parts[1]}
    </>
  );
}
