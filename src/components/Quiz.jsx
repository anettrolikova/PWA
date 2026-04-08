import { useState, useMemo } from 'react';
import { questions, CATEGORIES } from '../data/questions.js';
import QuestionCard from './QuestionCard.jsx';
import ExplanationCard from './ExplanationCard.jsx';
import ResultScreen from './ResultScreen.jsx';

const SESSION_SIZE = 8;

function pickQuestions() {
  const shuffled = [...questions].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, SESSION_SIZE);
}

export default function Quiz({ onFinish, onBack }) {
  const sessionQuestions = useMemo(() => pickQuestions(), []);
  const [currentIdx, setCurrentIdx] = useState(0);
  const [phase, setPhase] = useState('question'); // 'question' | 'explanation' | 'done'
  const [results, setResults] = useState([]); // { category, correct, chosen, question }
  const [chosen, setChosen] = useState(null);

  const current = sessionQuestions[currentIdx];
  const total = sessionQuestions.length;

  function handleAnswer(option) {
    const correct = option === current.answer;
    setChosen(option);
    setResults((prev) => [...prev, { category: current.category, correct, chosen: option, question: current }]);
    setPhase('explanation');
  }

  function handleNext() {
    if (currentIdx + 1 >= total) {
      setPhase('done');
    } else {
      setCurrentIdx((i) => i + 1);
      setChosen(null);
      setPhase('question');
    }
  }

  if (phase === 'done') {
    return <ResultScreen results={results} onFinish={() => onFinish(results)} />;
  }

  const progress = ((currentIdx + (phase === 'explanation' ? 1 : 0)) / total) * 100;

  return (
    <div className="screen quiz">
      {/* Top bar */}
      <div className="quiz-topbar">
        <button className="btn-back" onClick={onBack} aria-label="Back to dashboard">
          ←
        </button>
        <div className="quiz-progress-wrap">
          <div className="quiz-progress-track">
            <div className="quiz-progress-fill" style={{ width: `${progress}%` }} />
          </div>
          <span className="quiz-counter">{currentIdx + 1} / {total}</span>
        </div>
        <div className="category-tag" style={{ color: CATEGORIES[current.category]?.color }}>
          {CATEGORIES[current.category]?.label}
        </div>
      </div>

      {phase === 'question' && (
        <QuestionCard question={current} onAnswer={handleAnswer} />
      )}

      {phase === 'explanation' && (
        <ExplanationCard
          question={current}
          chosen={chosen}
          onNext={handleNext}
          isLast={currentIdx + 1 >= total}
        />
      )}
    </div>
  );
}
