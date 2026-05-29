import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { MapPin, Satellite, Navigation } from 'lucide-react';
import { Screen } from '../App';

interface LiveMonitorScreenProps {
  navigateTo: (screen: Screen) => void;
}

export default function LiveMonitorScreen({ navigateTo }: LiveMonitorScreenProps) {
  const [currentSpeed, setCurrentSpeed] = useState(65);
  const [speedLimit] = useState(60);
  const [countdown, setCountdown] = useState(15);
  const [satellites] = useState(8);
  const [accuracy] = useState(2);

  const status = currentSpeed > speedLimit + 10 ? 'violation' : currentSpeed > speedLimit ? 'warning' : 'safe';

  const getStatusColor = () => {
    switch (status) {
      case 'safe': return '#22c55e';
      case 'warning': return '#f59e0b';
      case 'violation': return '#ef4444';
      default: return '#22c55e';
    }
  };

  const getStatusText = () => {
    switch (status) {
      case 'safe': return '✓ SAFE';
      case 'warning': return '⚠ WARNING';
      case 'violation': return '⚠ VIOLATION';
      default: return '✓ SAFE';
    }
  };

  // Simulate speed changes
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSpeed(prev => {
        const change = (Math.random() - 0.5) * 8;
        return Math.max(0, Math.min(120, prev + change));
      });
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  // Countdown timer when warning/violation
  useEffect(() => {
    if (status !== 'safe') {
      const interval = setInterval(() => {
        setCountdown(prev => {
          if (prev <= 1) return 30;
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(interval);
    } else {
      setCountdown(30);
    }
  }, [status]);

  return (
    <div className="min-h-screen bg-white pb-20">
      {/* Map View */}
      <div className="relative h-80 bg-gradient-to-br from-[#e0f2fe] to-[#bae6fd] overflow-hidden">
        {/* Simulated map with grid */}
        <div className="absolute inset-0 opacity-20">
          <svg width="100%" height="100%">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#94a3b8" strokeWidth="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>

        {/* Car icon in center */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <motion.div
            animate={{ y: [0, -4, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-12 h-12 rounded-full flex items-center justify-center"
            style={{ 
              background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
              boxShadow: '0 4px 12px rgba(235, 68, 37, 0.5)'
            }}
          >
            <Navigation className="w-6 h-6 text-white" />
          </motion.div>
        </div>

        {/* Speed overlay on map */}
        <div className="absolute top-4 right-4 bg-white bg-opacity-90 backdrop-blur-sm rounded-2xl px-4 py-2 shadow-lg">
          <div 
            className="text-3xl"
            style={{ 
              color: getStatusColor(),
              fontFamily: 'Roboto Mono, monospace'
            }}
          >
            {currentSpeed}
          </div>
          <div className="text-xs text-[#6b7280]">km/h</div>
        </div>

        {/* Location info */}
        <div className="absolute bottom-4 left-4 bg-white bg-opacity-90 backdrop-blur-sm rounded-lg px-3 py-2 shadow-lg flex items-center gap-2">
          <MapPin className="w-4 h-4 text-[#3b82f6]" />
          <div className="text-xs text-[#1f2937]">Cairo-Alexandria Road</div>
        </div>
      </div>

      {/* Speed Card */}
      <div className="px-4 -mt-8 mb-4">
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="bg-white rounded-xl p-4 border-2"
          style={{ 
            borderColor: getStatusColor(),
            boxShadow: '0px 4px 6px rgba(0, 0, 0, 0.07)'
          }}
        >
          <div className="flex items-center justify-between mb-3">
            <div>
              <div className="text-sm text-[#6b7280] mb-1">Current Speed</div>
              <div 
                className="text-5xl"
                style={{ 
                  color: getStatusColor(),
                  fontFamily: 'Roboto Mono, monospace'
                }}
              >
                {currentSpeed}
              </div>
            </div>
            <div className="text-right">
              <div className="text-sm text-[#6b7280] mb-1">Speed Limit</div>
              <div className="text-3xl text-[#1f2937]">{speedLimit}</div>
            </div>
          </div>

          <div className="flex items-center justify-between mb-2">
            <div className="text-sm" style={{ color: getStatusColor() }}>
              {getStatusText()}
            </div>
            {status !== 'safe' && (
              <div className="text-sm text-[#6b7280]">
                Slow down in {countdown} seconds
              </div>
            )}
          </div>

          {/* Progress bar */}
          {status !== 'safe' && (
            <div className="h-2 bg-[#e5e7eb] rounded-full overflow-hidden">
              <motion.div
                className="h-full rounded-full"
                style={{ 
                  backgroundColor: getStatusColor(),
                  width: `${(countdown / 30) * 100}%`
                }}
                animate={{ width: `${(countdown / 30) * 100}%` }}
                transition={{ duration: 1, ease: 'linear' }}
              />
            </div>
          )}
        </motion.div>
      </div>

      {/* GPS Info Cards */}
      <div className="px-4">
        <div className="grid grid-cols-2 gap-3">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-[#f8f9fa] rounded-xl p-4"
          >
            <div className="flex items-center gap-2 mb-2">
              <Satellite className="w-5 h-5 text-[#3b82f6]" />
              <div className="text-sm text-[#6b7280]">Satellites</div>
            </div>
            <div className="text-2xl text-[#1f2937]">{satellites}</div>
            <div className="text-xs text-[#22c55e] mt-1">● Connected</div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
            className="bg-[#f8f9fa] rounded-xl p-4"
          >
            <div className="flex items-center gap-2 mb-2">
              <MapPin className="w-5 h-5 text-[#22c55e]" />
              <div className="text-sm text-[#6b7280]">Accuracy</div>
            </div>
            <div className="text-2xl text-[#1f2937]">±{accuracy}m</div>
            <div className="text-xs text-[#22c55e] mt-1">● Excellent</div>
          </motion.div>
        </div>
      </div>

      {/* Additional Info */}
      <div className="px-4 mt-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-white border border-[#e5e7eb] rounded-lg p-4"
        >
          <div className="text-sm text-[#1f2937] mb-2">Trip Information</div>
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <div className="text-xs text-[#6b7280] mb-1">Distance</div>
              <div className="text-base text-[#1f2937]">12.5 km</div>
            </div>
            <div>
              <div className="text-xs text-[#6b7280] mb-1">Duration</div>
              <div className="text-base text-[#1f2937]">18 min</div>
            </div>
            <div>
              <div className="text-xs text-[#6b7280] mb-1">Avg Speed</div>
              <div className="text-base text-[#1f2937]">58 km/h</div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
