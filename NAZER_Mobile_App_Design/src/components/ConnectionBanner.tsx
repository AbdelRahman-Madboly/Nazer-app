import { motion } from 'motion/react';
import { Bluetooth, Loader2 } from 'lucide-react';

interface ConnectionBannerProps {
  status: 'disconnected' | 'offline' | 'connected';
  onConnect: () => void;
}

export default function ConnectionBanner({ status, onConnect }: ConnectionBannerProps) {
  if (status === 'connected') return null;

  if (status === 'disconnected') {
    return (
      <motion.div
        initial={{ y: -60, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: -60, opacity: 0 }}
        className="bg-[#3b82f6] text-white px-4 py-3 flex items-center justify-between"
      >
        <div className="flex items-center gap-3">
          <Bluetooth className="w-5 h-5" />
          <div>
            <div className="text-sm">Device Not Connected</div>
            <div className="text-xs opacity-90">Tap to connect your NAZER device</div>
          </div>
        </div>
        <button
          onClick={onConnect}
          className="bg-white text-[#3b82f6] px-3 py-1 rounded text-sm hover:bg-opacity-90 transition-colors"
        >
          Connect
        </button>
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ y: -50, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      exit={{ y: -50, opacity: 0 }}
      className="bg-[#f59e0b] text-white px-4 py-2.5 flex items-center gap-3"
    >
      <Loader2 className="w-4 h-4 animate-spin" />
      <div>
        <div className="text-sm">Device Offline</div>
        <div className="text-xs opacity-90">Waiting for NAZER_001 to power on...</div>
      </div>
    </motion.div>
  );
}
