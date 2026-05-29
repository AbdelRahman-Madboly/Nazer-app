import { motion } from 'motion/react';
import { CheckCircle, Car, AlertTriangle, Trophy } from 'lucide-react';
import { Screen } from '../App';

interface DriverScoreScreenProps {
  navigateTo: (screen: Screen) => void;
}

export default function DriverScoreScreen({ navigateTo }: DriverScoreScreenProps) {
  const score = 85;
  const maxScore = 100;
  const percentage = (score / maxScore) * 100;
  const circumference = 2 * Math.PI * 70;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  const getScoreLevel = () => {
    if (score >= 80) return { text: 'EXCELLENT DRIVER', color: '#22c55e' };
    if (score >= 60) return { text: 'GOOD DRIVER', color: '#3b82f6' };
    if (score >= 40) return { text: 'FAIR DRIVER', color: '#f59e0b' };
    return { text: 'POOR DRIVER', color: '#ef4444' };
  };

  const level = getScoreLevel();

  const breakdown = [
    { icon: CheckCircle, label: 'Safe Driving', points: 50, color: '#22c55e' },
    { icon: Car, label: 'Distance', points: 30, color: '#3b82f6' },
    { icon: AlertTriangle, label: 'Violations', points: -15, color: '#ef4444' },
    { icon: Trophy, label: 'Bonuses', points: 20, color: '#f59e0b' },
  ];

  const achievements = [
    { emoji: '🏅', title: '7-Day Safe Streak', description: 'No violations for 7 days' },
    { emoji: '🌟', title: '100km Safe Driving', description: 'Drove 100km without violations' },
    { emoji: '⭐', title: 'Speed Master', description: 'Maintained speed limits for 5 days' },
  ];

  return (
    <div className="min-h-screen bg-white pb-20">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb]">
        <h1 className="text-2xl text-[#1f2937]">Driver Score</h1>
      </div>

      {/* Score Circle */}
      <div className="px-4 py-8 flex flex-col items-center">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="relative w-48 h-48 mb-4"
        >
          <svg className="w-full h-full -rotate-90">
            {/* Background track */}
            <circle
              cx="96"
              cy="96"
              r="70"
              stroke="#e5e7eb"
              strokeWidth="16"
              fill="none"
              strokeLinecap="round"
            />
            {/* Progress track with gradient */}
            <defs>
              <linearGradient id="scoreGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#22c55e" />
                <stop offset="100%" stopColor="#3b82f6" />
              </linearGradient>
            </defs>
            <motion.circle
              cx="96"
              cy="96"
              r="70"
              stroke="url(#scoreGradient)"
              strokeWidth="16"
              fill="none"
              strokeLinecap="round"
              strokeDasharray={circumference}
              initial={{ strokeDashoffset: circumference }}
              animate={{ strokeDashoffset }}
              transition={{ duration: 1, ease: 'easeOut' }}
            />
          </svg>

          {/* Score number */}
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.3, duration: 0.5, type: 'spring' }}
              className="text-6xl text-[#1f2937]"
              style={{ fontFamily: 'Roboto Mono, monospace' }}
            >
              {score}
            </motion.div>
            <div className="text-sm text-[#6b7280]">of {maxScore}</div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="text-lg"
          style={{ color: level.color }}
        >
          {level.text}
        </motion.div>
      </div>

      {/* Score Breakdown */}
      <div className="px-4 mb-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="bg-white border border-[#e5e7eb] rounded-xl p-4"
        >
          <h2 className="text-lg text-[#1f2937] mb-4">Score Breakdown</h2>

          <div className="space-y-3 mb-4">
            {breakdown.map((item, index) => {
              const Icon = item.icon;
              return (
                <motion.div
                  key={item.label}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.7 + index * 0.1 }}
                  className="flex items-center justify-between py-2"
                >
                  <div className="flex items-center gap-3">
                    <div
                      className="w-8 h-8 rounded-full flex items-center justify-center"
                      style={{ backgroundColor: `${item.color}20` }}
                    >
                      <Icon className="w-4 h-4" style={{ color: item.color }} />
                    </div>
                    <span className="text-sm text-[#1f2937]">{item.label}</span>
                  </div>
                  <span
                    className="text-base"
                    style={{ color: item.points > 0 ? '#22c55e' : '#ef4444' }}
                  >
                    {item.points > 0 ? '+' : ''}{item.points}
                  </span>
                </motion.div>
              );
            })}
          </div>

          <div className="pt-3 border-t border-[#e5e7eb] flex items-center justify-between">
            <span className="text-base text-[#1f2937]">Total Score</span>
            <span className="text-2xl text-[#1f2937]">{score}</span>
          </div>
        </motion.div>
      </div>

      {/* Achievements */}
      <div className="px-4 mb-6">
        <h2 className="text-lg text-[#1f2937] mb-3">Achievements</h2>

        <div className="space-y-3">
          {achievements.map((achievement, index) => (
            <motion.div
              key={achievement.title}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.1 + index * 0.1 }}
              className="bg-gradient-to-r from-[#fef3c7] to-[#fde68a] border border-[#fbbf24] rounded-xl p-4 flex items-start gap-3"
            >
              <div className="text-3xl">{achievement.emoji}</div>
              <div className="flex-1">
                <div className="text-base text-[#1f2937] mb-1">{achievement.title}</div>
                <div className="text-sm text-[#6b7280]">{achievement.description}</div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Tips */}
      <div className="px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.4 }}
          className="bg-[#dbeafe] border border-[#3b82f6] rounded-xl p-4"
        >
          <div className="flex items-start gap-2">
            <div className="text-xl">💡</div>
            <div>
              <div className="text-sm text-[#1f2937] mb-1">How to improve your score:</div>
              <ul className="text-xs text-[#6b7280] space-y-1">
                <li>• Maintain speed limits consistently</li>
                <li>• Drive more kilometers safely</li>
                <li>• Pay fines on time</li>
                <li>• Build safe driving streaks</li>
              </ul>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
