const CORRECT_LINES = [
  'Nailed it.',
  'Exactly right.',
  'That\'s the one.',
  'Sharp.',
  'Correct — native speakers would say the same.',
  'You got it.',
  'Spot on.',
  'Yes! That\'s the natural choice.',
];

const WRONG_LINES = [
  'Not quite — but now you know.',
  'Close. Here\'s what\'s actually going on:',
  'Common mistake — this is why:',
  'Not this time. Read on.',
  'A lot of people get this wrong. Here\'s the rule:',
  'Good try. The real answer:',
];

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

export default function ExplanationCard({ question, chosen, onNext, isLast }) {
  const isCorrect = chosen === question.answer;
  const headline = isCorrect ? pick(CORRECT_LINES) : pick(WRONG_LINES);

  return (
    <div className="explanation-card">
      <div className={`result-badge ${isCorrect ? 'result-correct' : 'result-wrong'}`}>
        {isCorrect ? '✓' : '✗'}
      </div>

      <p className="result-headline">{headline}</p>

      {!isCorrect && (
        <div className="correct-answer-row">
          <span className="correct-label">Correct answer:</span>
          <span className="correct-value">{question.answer}</span>
        </div>
      )}

      <div className="explanation-text">
        <span className="explanation-quote">"</span>
        {question.explanation}
      </div>

      <div className="question-recap">
        {formatQuestion(question.question, question.answer)}
      </div>

      <button className="btn-primary" onClick={onNext}>
        {isLast ? 'See results' : 'Next question'}
      </button>
    </div>
  );
}

function formatQuestion(text, answer) {
  const parts = text.split('___');
  if (parts.length === 1) return <span className="recap-text">{text}</span>;
  return (
    <span className="recap-text">
      {parts[0]}
      <span className="recap-answer">{answer}</span>
      {parts[1]}
    </span>
  );
}
