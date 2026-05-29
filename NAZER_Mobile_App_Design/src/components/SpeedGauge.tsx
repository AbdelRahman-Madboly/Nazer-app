import { motion } from 'motion/react';
import { useEffect, useState } from 'react';

interface SpeedGaugeProps {
  speed: number;
  limit: number;
  status: 'safe' | 'warning' | 'violation';
}

export default function SpeedGauge({ speed, limit, status }: SpeedGaugeProps) {
  const [animatedSpeed, setAnimatedSpeed] = useState(0);

  useEffect(() => {
    setAnimatedSpeed(speed);
  }, [speed]);

  const getColor = () => {
    switch (status) {
      case 'safe':
        return '#22c55e';
      case 'warning':
        return '#f59e0b';
      case 'violation':
        return '#ef4444';
      default:
        return '#22c55e';
    }
  };

  const getStatusText = () => {
    switch (status) {
      case 'safe':
        return 'SAFE DRIVING';
      case 'warning':
        return 'SPEED WARNING';
      case 'violation':
        return 'VIOLATION';
      default:
        return 'SAFE DRIVING';
    }
  };

  const percentage = Math.min((speed / 120) * 100, 100);
  const circumference = 2 * Math.PI * 90;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  return (
    <div className="flex flex-col items-center">
      {/* Circular Gauge */}
      <div className="relative w-52 h-52 mb-4">
        <svg className="w-full h-full -rotate-90">
          {/* Background track */}
          <circle
            cx="104"
            cy="104"
            r="90"
            stroke="#e5e7eb"
            strokeWidth="12"
            fill="none"
            strokeLinecap="round"
          />
          {/* Progress track */}
          <motion.circle
            cx="104"
            cy="104"
            r="90"
            stroke={getColor()}
            strokeWidth="12"
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            initial={{ strokeDashoffset: circumference }}
            animate={{ strokeDashoffset }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            style={{
              filter: status === 'violation' ? 'drop-shadow(0 0 8px rgba(239, 68, 68, 0.6))' : 'none'
            }}
          />
        </svg>

        {/* Speed number */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <motion.div
            key={animatedSpeed}
            initial={{ scale: 1 }}
            animate={{ scale: status === 'violation' ? [1, 1.05, 1] : 1 }}
            transition={{ duration: 0.5 }}
            className="text-7xl"
            style={{ 
              color: getColor(),
              fontFamily: 'Roboto Mono, monospace'
            }}
          >
            {animatedSpeed}
          </motion.div>
          <div className="text-base text-[#6b7280] -mt-2">km/h</div>
        </div>
      </div>

      {/* Speed Limit Info */}
      <div className="text-sm text-[#6b7280] mb-2">
        Limit: {limit} km/h
      </div>

      {/* Status Indicator */}
      <div className="flex items-center gap-2">
        <motion.div
          animate={{ 
            scale: status === 'violation' ? [1, 1.2, 1] : 1,
            opacity: status === 'violation' ? [1, 0.7, 1] : 1
          }}
          transition={{ 
            duration: 0.5, 
            repeat: status === 'violation' ? Infinity : 0,
            repeatDelay: 0.5
          }}
          className="w-2 h-2 rounded-full"
          style={{ backgroundColor: getColor() }}
        />
        <div className="text-sm" style={{ color: getColor() }}>
          {getStatusText()}
        </div>
      </div>

      {/* Warning message for violation */}
      {status === 'violation' && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-4 px-4 py-2 bg-[#fee2e2] rounded-lg text-sm text-[#ef4444] text-center"
        >
          Slow down immediately to avoid fine!
        </motion.div>
      )}
    </div>
  );
}
