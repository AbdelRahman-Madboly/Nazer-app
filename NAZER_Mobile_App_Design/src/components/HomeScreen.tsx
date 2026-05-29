import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Bluetooth, Star, AlertTriangle, MapPin } from 'lucide-react';
import SpeedGauge from './SpeedGauge';
import ConnectionBanner from './ConnectionBanner';
import { Screen } from '../App';

interface HomeScreenProps {
  navigateTo: (screen: Screen, data?: any) => void;
}

export default function HomeScreen({ navigateTo }: HomeScreenProps) {
  const [currentSpeed, setCurrentSpeed] = useState(65);
  const [speedLimit, setSpeedLimit] = useState(60);
  const [connectionStatus, setConnectionStatus] = useState<'disconnected' | 'offline' | 'connected'>('connected');
  
  // Simulate speed changes
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSpeed(prev => {
        const change = (Math.random() - 0.5) * 10;
        return Math.max(0, Math.min(120, prev + change));
      });
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const status = currentSpeed > speedLimit + 10 ? 'violation' : currentSpeed > speedLimit ? 'warning' : 'safe';

  return (
    <div className="min-h-screen bg-white pb-20">
      {/* Connection Banner */}
      {connectionStatus !== 'connected' && (
        <ConnectionBanner status={connectionStatus} onConnect={() => navigateTo('settings')} />
      )}

      {/* Hero Section - Speed Display */}
      <div className="px-4 pt-12 pb-6">
        <SpeedGauge 
          speed={Math.round(currentSpeed)} 
          limit={speedLimit}
          status={status}
        />
      </div>

      {/* Quick Stats Cards */}
      <div className="px-4 mb-6">
        <div className="grid grid-cols-3 gap-3">
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => navigateTo('score')}
            className="bg-[#f8f9fa] rounded-xl p-3 flex flex-col items-center justify-center h-20"
            style={{ boxShadow: '0px 1px 3px rgba(0, 0, 0, 0.1)' }}
          >
            <Star className="w-6 h-6 text-[#f59e0b] mb-1" />
            <div className="text-xl text-[#1f2937]">85</div>
            <div className="text-xs text-[#6b7280]">Score</div>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => navigateTo('violations')}
            className="bg-[#f8f9fa] rounded-xl p-3 flex flex-col items-center justify-center h-20"
            style={{ boxShadow: '0px 1px 3px rgba(0, 0, 0, 0.1)' }}
          >
            <AlertTriangle className="w-6 h-6 text-[#ef4444] mb-1" />
            <div className="text-xl text-[#1f2937]">3</div>
            <div className="text-xs text-[#6b7280]">Fines</div>
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.95 }}
            className="bg-[#f8f9fa] rounded-xl p-3 flex flex-col items-center justify-center h-20"
            style={{ boxShadow: '0px 1px 3px rgba(0, 0, 0, 0.1)' }}
          >
            <MapPin className="w-6 h-6 text-[#3b82f6] mb-1" />
            <div className="text-xl text-[#1f2937]">0</div>
            <div className="text-xs text-[#6b7280]">Today</div>
          </motion.button>
        </div>
      </div>

      {/* Recent Activity Section */}
      <div className="px-4">
        <h2 className="text-lg mb-3 text-[#1f2937]">Recent Activity</h2>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="bg-white border border-[#e5e7eb] rounded-lg p-3 mb-2"
        >
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[#fee2e2] flex items-center justify-center flex-shrink-0">
              <AlertTriangle className="w-5 h-5 text-[#ef4444]" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-[#1f2937] mb-1">Speed Violation</div>
              <div className="text-sm text-[#6b7280] mb-1">95 km/h in 60 km/h zone</div>
              <div className="text-xs text-[#9ca3af]">10:30 AM • $10.00</div>
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.05 }}
          className="bg-white border border-[#e5e7eb] rounded-lg p-3 mb-2"
        >
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[#d1fae5] flex items-center justify-center flex-shrink-0">
              <Star className="w-5 h-5 text-[#22c55e]" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-[#1f2937] mb-1">Safe Driving Streak</div>
              <div className="text-sm text-[#6b7280] mb-1">7 days without violations</div>
              <div className="text-xs text-[#9ca3af]">Keep it up!</div>
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.1 }}
          className="bg-white border border-[#e5e7eb] rounded-lg p-3"
        >
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-full bg-[#dbeafe] flex items-center justify-center flex-shrink-0">
              <Bluetooth className="w-5 h-5 text-[#3b82f6]" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-[#1f2937] mb-1">Device Connected</div>
              <div className="text-sm text-[#6b7280] mb-1">NAZER_001 paired successfully</div>
              <div className="text-xs text-[#9ca3af]">Yesterday</div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
