import { motion } from 'motion/react';
import { ArrowLeft, MapPin, Clock, AlertTriangle } from 'lucide-react';
import { Screen, Violation } from '../App';

interface ViolationDetailScreenProps {
  violation: Violation;
  navigateTo: (screen: Screen, data?: any) => void;
}

export default function ViolationDetailScreen({ violation, navigateTo }: ViolationDetailScreenProps) {
  const getStatusBadge = (status: Violation['status']) => {
    const styles = {
      unpaid: { bg: '#fef3c7', text: '#f59e0b' },
      paid: { bg: '#d1fae5', text: '#22c55e' },
      disputed: { bg: '#dbeafe', text: '#3b82f6' }
    };
    const style = styles[status];
    
    return (
      <span
        className="text-xs px-2 py-1 rounded"
        style={{ backgroundColor: style.bg, color: style.text }}
      >
        {status.toUpperCase()}
      </span>
    );
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb] flex items-center gap-3">
        <button
          onClick={() => navigateTo('violations')}
          className="p-2 -ml-2 hover:bg-[#f8f9fa] rounded-lg transition-colors"
        >
          <ArrowLeft className="w-6 h-6 text-[#1f2937]" />
        </button>
        <h1 className="text-xl text-[#1f2937]">Violation #{violation.id}</h1>
      </div>

      {/* Map View */}
      <div className="relative h-52 bg-gradient-to-br from-[#fee2e2] to-[#fecaca] overflow-hidden">
        {/* Simulated map */}
        <div className="absolute inset-0 opacity-20">
          <svg width="100%" height="100%">
            <defs>
              <pattern id="violation-grid" width="30" height="30" patternUnits="userSpaceOnUse">
                <path d="M 30 0 L 0 0 0 30" fill="none" stroke="#ef4444" strokeWidth="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#violation-grid)" />
          </svg>
        </div>

        {/* Violation marker */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
          <motion.div
            animate={{ scale: [1, 1.1, 1] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-12 h-12 rounded-full bg-[#ef4444] flex items-center justify-center shadow-lg"
          >
            <AlertTriangle className="w-6 h-6 text-white" />
          </motion.div>
        </div>

        {/* Coordinates */}
        <div className="absolute bottom-3 left-3 bg-white bg-opacity-90 backdrop-blur-sm rounded-lg px-3 py-1.5 text-xs text-[#6b7280]">
          {violation.coordinates.lat.toFixed(4)}°N, {violation.coordinates.lng.toFixed(4)}°E
        </div>
      </div>

      {/* Details Card */}
      <div className="px-4 -mt-6 mb-4">
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="bg-white rounded-xl p-5 shadow-lg border border-[#e5e7eb]"
        >
          <div className="flex items-start gap-3 mb-4">
            <div className="w-12 h-12 rounded-full bg-[#fee2e2] flex items-center justify-center flex-shrink-0">
              <AlertTriangle className="w-6 h-6 text-[#ef4444]" />
            </div>
            <div className="flex-1">
              <h2 className="text-xl text-[#1f2937] mb-1">{violation.type}</h2>
              <div>{getStatusBadge(violation.status)}</div>
            </div>
          </div>

          <div className="space-y-3 mb-4">
            <div className="flex justify-between items-center py-2 border-b border-[#f3f4f6]">
              <span className="text-sm text-[#6b7280]">Your Speed:</span>
              <span className="text-base text-[#ef4444]">{violation.speed} km/h</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-[#f3f4f6]">
              <span className="text-sm text-[#6b7280]">Speed Limit:</span>
              <span className="text-base text-[#1f2937]">{violation.limit} km/h</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-[#f3f4f6]">
              <span className="text-sm text-[#6b7280]">Exceeded by:</span>
              <span className="text-base text-[#f59e0b]">{violation.speed - violation.limit} km/h</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b border-[#f3f4f6]">
              <span className="text-sm text-[#6b7280]">Fine Amount:</span>
              <span className="text-2xl text-[#1f2937]">${violation.amount.toFixed(2)}</span>
            </div>
          </div>

          <div className="space-y-2 pt-3 border-t border-[#e5e7eb]">
            <div className="flex items-start gap-2">
              <Clock className="w-4 h-4 text-[#6b7280] mt-0.5" />
              <div>
                <div className="text-sm text-[#6b7280]">Date & Time</div>
                <div className="text-sm text-[#1f2937]">{violation.date} • {violation.time}</div>
              </div>
            </div>
            <div className="flex items-start gap-2">
              <MapPin className="w-4 h-4 text-[#6b7280] mt-0.5" />
              <div>
                <div className="text-sm text-[#6b7280]">Location</div>
                <div className="text-sm text-[#1f2937]">{violation.location}</div>
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Action Buttons */}
      {violation.status === 'unpaid' && (
        <div className="px-4 pb-6">
          <div className="grid grid-cols-2 gap-3">
            <motion.button
              whileTap={{ scale: 0.95 }}
              className="py-3 px-4 rounded-lg border border-[#e5e7eb] text-[#6b7280] bg-white hover:bg-[#f8f9fa] transition-colors"
            >
              Dispute
            </motion.button>
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => navigateTo('payment-method', { amount: violation.amount })}
              className="py-3 px-4 rounded-lg text-white"
              style={{
                background: 'linear-gradient(135deg, #992a17 0%, #eb4425 100%)',
                boxShadow: '0px 4px 6px rgba(235, 68, 37, 0.3)'
              }}
            >
              Pay Now
            </motion.button>
          </div>
        </div>
      )}

      {violation.status === 'paid' && (
        <div className="px-4 pb-6">
          <div className="bg-[#d1fae5] border border-[#22c55e] rounded-lg p-4 text-center">
            <div className="text-2xl mb-2">✓</div>
            <div className="text-sm text-[#22c55e]">This fine has been paid</div>
          </div>
        </div>
      )}
    </div>
  );
}
