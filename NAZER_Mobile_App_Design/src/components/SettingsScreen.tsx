import { useState } from 'react';
import { motion } from 'motion/react';
import { 
  ArrowLeft, 
  Car, 
  Bell, 
  Volume2, 
  Vibrate, 
  Moon, 
  Globe, 
  Ruler,
  ChevronRight,
  Shield,
  FileText
} from 'lucide-react';
import { Screen } from '../App';

interface SettingsScreenProps {
  navigateTo: (screen: Screen) => void;
}

export default function SettingsScreen({ navigateTo }: SettingsScreenProps) {
  const [pushNotifications, setPushNotifications] = useState(true);
  const [soundAlerts, setSoundAlerts] = useState(true);
  const [vibration, setVibration] = useState(true);
  const [darkMode, setDarkMode] = useState(false);

  const ToggleSwitch = ({ value, onChange }: { value: boolean; onChange: (v: boolean) => void }) => (
    <button
      onClick={() => onChange(!value)}
      className="relative w-12 h-7 rounded-full transition-colors"
      style={{ backgroundColor: value ? '#eb4425' : '#e5e7eb' }}
    >
      <motion.div
        animate={{ x: value ? 20 : 2 }}
        transition={{ type: 'spring', stiffness: 500, damping: 30 }}
        className="absolute top-1 w-5 h-5 bg-white rounded-full shadow-md"
      />
    </button>
  );

  const SettingItem = ({ 
    icon: Icon, 
    label, 
    action, 
    iconColor = '#6b7280' 
  }: { 
    icon: any; 
    label: string; 
    action: React.ReactNode; 
    iconColor?: string;
  }) => (
    <div className="flex items-center justify-between py-4 border-b border-[#e5e7eb]">
      <div className="flex items-center gap-3">
        <Icon className="w-6 h-6" style={{ color: iconColor }} />
        <span className="text-base text-[#1f2937]">{label}</span>
      </div>
      {action}
    </div>
  );

  const SettingLink = ({ 
    icon: Icon, 
    label, 
    value,
    iconColor = '#6b7280' 
  }: { 
    icon: any; 
    label: string; 
    value: string;
    iconColor?: string;
  }) => (
    <button className="w-full flex items-center justify-between py-4 border-b border-[#e5e7eb] hover:bg-[#f8f9fa] -mx-4 px-4 transition-colors">
      <div className="flex items-center gap-3">
        <Icon className="w-6 h-6" style={{ color: iconColor }} />
        <span className="text-base text-[#1f2937]">{label}</span>
      </div>
      <div className="flex items-center gap-2">
        <span className="text-sm text-[#6b7280]">{value}</span>
        <ChevronRight className="w-5 h-5 text-[#9ca3af]" />
      </div>
    </button>
  );

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 border-b border-[#e5e7eb] flex items-center gap-3">
        <button
          onClick={() => navigateTo('home')}
          className="p-2 -ml-2 hover:bg-[#f8f9fa] rounded-lg transition-colors"
        >
          <ArrowLeft className="w-6 h-6 text-[#1f2937]" />
        </button>
        <h1 className="text-2xl text-[#1f2937]">Settings</h1>
      </div>

      <div className="px-4 py-6">
        {/* Device Connection Section */}
        <div className="mb-8">
          <h2 className="text-xs text-[#9ca3af] mb-3" style={{ letterSpacing: '1px' }}>
            DEVICE CONNECTION
          </h2>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white border border-[#e5e7eb] rounded-xl p-4"
          >
            <div className="flex items-start gap-3 mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#992a17] to-[#eb4425] flex items-center justify-center flex-shrink-0">
                <Car className="w-6 h-6 text-white" />
              </div>
              <div className="flex-1">
                <div className="text-base text-[#1f2937] mb-1">Connected Device</div>
                <div className="text-sm text-[#6b7280]">NAZER_001</div>
                <div className="flex items-center gap-1 mt-2">
                  <div className="w-2 h-2 rounded-full bg-[#22c55e]" />
                  <span className="text-xs text-[#22c55e]">Connected</span>
                </div>
              </div>
            </div>
            <button className="w-full py-2.5 border border-[#e5e7eb] rounded-lg text-sm text-[#6b7280] hover:bg-[#f8f9fa] transition-colors">
              Change Device
            </button>
          </motion.div>
        </div>

        {/* Notifications Section */}
        <div className="mb-8">
          <h2 className="text-xs text-[#9ca3af] mb-3" style={{ letterSpacing: '1px' }}>
            NOTIFICATIONS
          </h2>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white border border-[#e5e7eb] rounded-xl px-4"
          >
            <SettingItem
              icon={Bell}
              label="Push Notifications"
              iconColor="#3b82f6"
              action={<ToggleSwitch value={pushNotifications} onChange={setPushNotifications} />}
            />
            <SettingItem
              icon={Volume2}
              label="Sound Alerts"
              iconColor="#f59e0b"
              action={<ToggleSwitch value={soundAlerts} onChange={setSoundAlerts} />}
            />
            <SettingItem
              icon={Vibrate}
              label="Vibration"
              iconColor="#8b5cf6"
              action={<ToggleSwitch value={vibration} onChange={setVibration} />}
            />
          </motion.div>
        </div>

        {/* App Preferences Section */}
        <div className="mb-8">
          <h2 className="text-xs text-[#9ca3af] mb-3" style={{ letterSpacing: '1px' }}>
            APP PREFERENCES
          </h2>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white border border-[#e5e7eb] rounded-xl px-4"
          >
            <SettingItem
              icon={Moon}
              label="Dark Mode"
              iconColor="#6366f1"
              action={<ToggleSwitch value={darkMode} onChange={setDarkMode} />}
            />
            <div className="border-b border-[#e5e7eb]">
              <SettingLink
                icon={Globe}
                label="Language"
                value="English"
                iconColor="#22c55e"
              />
            </div>
            <div>
              <SettingLink
                icon={Ruler}
                label="Units"
                value="Metric"
                iconColor="#ef4444"
              />
            </div>
          </motion.div>
        </div>

        {/* About Section */}
        <div>
          <h2 className="text-xs text-[#9ca3af] mb-3" style={{ letterSpacing: '1px' }}>
            ABOUT
          </h2>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white border border-[#e5e7eb] rounded-xl px-4"
          >
            <div className="py-4 border-b border-[#e5e7eb]">
              <div className="text-sm text-[#6b7280] mb-1">Version</div>
              <div className="text-base text-[#1f2937]">1.0.0</div>
            </div>
            <div className="border-b border-[#e5e7eb]">
              <SettingLink
                icon={Shield}
                label="Privacy Policy"
                value=""
                iconColor="#3b82f6"
              />
            </div>
            <div>
              <SettingLink
                icon={FileText}
                label="Terms of Service"
                value=""
                iconColor="#3b82f6"
              />
            </div>
          </motion.div>
        </div>

        {/* App Info */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="mt-8 text-center"
        >
          <div className="text-xs text-[#9ca3af] mb-2">Made with ❤️ for safer driving</div>
          <div className="text-xs text-[#9ca3af]">© 2025 NAZER. All rights reserved.</div>
        </motion.div>
      </div>
    </div>
  );
}
