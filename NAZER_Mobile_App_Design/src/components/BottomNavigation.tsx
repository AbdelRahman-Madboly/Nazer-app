import { Home, Gauge, Receipt, Star } from 'lucide-react';
import { motion } from 'motion/react';
import { Screen } from '../App';

interface BottomNavigationProps {
  currentScreen: Screen;
  navigateTo: (screen: Screen) => void;
}

export default function BottomNavigation({ currentScreen, navigateTo }: BottomNavigationProps) {
  const items = [
    { id: 'home' as Screen, icon: Home, label: 'Home' },
    { id: 'live' as Screen, icon: Gauge, label: 'Live' },
    { id: 'violations' as Screen, icon: Receipt, label: 'Fines' },
    { id: 'score' as Screen, icon: Star, label: 'Score' },
  ];

  return (
    <div 
      className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white border-t border-[#e5e7eb] h-16"
      style={{ boxShadow: '0 -4px 6px rgba(0, 0, 0, 0.05)' }}
    >
      <div className="flex items-center justify-around h-full px-2">
        {items.map((item) => {
          const Icon = item.icon;
          const isActive = currentScreen === item.id;
          
          return (
            <motion.button
              key={item.id}
              whileTap={{ scale: 0.95 }}
              onClick={() => navigateTo(item.id)}
              className="flex flex-col items-center justify-center flex-1 h-full gap-1"
            >
              <Icon 
                className="w-6 h-6" 
                style={{ 
                  color: isActive ? '#eb4425' : '#9ca3af',
                  strokeWidth: isActive ? 2.5 : 2
                }} 
              />
              <span 
                className="text-[10px]"
                style={{ color: isActive ? '#eb4425' : '#9ca3af' }}
              >
                {item.label}
              </span>
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}
