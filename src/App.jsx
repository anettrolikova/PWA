import { useState } from 'react';
import Dashboard from './components/Dashboard.jsx';
import Quiz from './components/Quiz.jsx';
import { useProgress } from './hooks/useProgress.js';

export default function App() {
  const [screen, setScreen] = useState('dashboard'); // 'dashboard' | 'quiz'
  const { progress, level, nextLevel, levelProgress, addSessionResult, resetProgress } = useProgress();

  return (
    <div className="app">
      {screen === 'dashboard' && (
        <Dashboard
          progress={progress}
          level={level}
          nextLevel={nextLevel}
          levelProgress={levelProgress}
          onStartQuiz={() => setScreen('quiz')}
          onReset={resetProgress}
        />
      )}
      {screen === 'quiz' && (
        <Quiz
          onFinish={(results) => {
            addSessionResult(results);
            setScreen('dashboard');
          }}
          onBack={() => setScreen('dashboard')}
        />
      )}
    </div>
  );
}
