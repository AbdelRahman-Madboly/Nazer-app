import { useState, useEffect } from 'react';
import SplashScreen from './components/SplashScreen';
import HomeScreen from './components/HomeScreen';
import LiveMonitorScreen from './components/LiveMonitorScreen';
import ViolationsListScreen from './components/ViolationsListScreen';
import ViolationDetailScreen from './components/ViolationDetailScreen';
import DriverScoreScreen from './components/DriverScoreScreen';
import PaymentMethodScreen from './components/PaymentMethodScreen';
import PaymentFormScreen from './components/PaymentFormScreen';
import PaymentSuccessScreen from './components/PaymentSuccessScreen';
import SettingsScreen from './components/SettingsScreen';
import BottomNavigation from './components/BottomNavigation';

export type Screen = 
  | 'splash'
  | 'home'
  | 'live'
  | 'violations'
  | 'violation-detail'
  | 'score'
  | 'payment-method'
  | 'payment-form'
  | 'payment-success'
  | 'settings';

export interface Violation {
  id: string;
  type: string;
  speed: number;
  limit: number;
  amount: number;
  location: string;
  coordinates: { lat: number; lng: number };
  date: string;
  time: string;
  status: 'paid' | 'unpaid' | 'disputed';
}

function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('splash');
  const [selectedViolation, setSelectedViolation] = useState<Violation | null>(null);
  const [paymentAmount, setPaymentAmount] = useState<number>(0);

  // Show splash screen for 2 seconds
  useEffect(() => {
    if (currentScreen === 'splash') {
      const timer = setTimeout(() => {
        setCurrentScreen('home');
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [currentScreen]);

  const navigateTo = (screen: Screen, data?: any) => {
    if (screen === 'violation-detail' && data) {
      setSelectedViolation(data);
    }
    if ((screen === 'payment-method' || screen === 'payment-form') && data?.amount) {
      setPaymentAmount(data.amount);
    }
    setCurrentScreen(screen);
  };

  const showNavigation = !['splash', 'payment-method', 'payment-form', 'payment-success', 'violation-detail', 'settings'].includes(currentScreen);

  return (
    <div className="min-h-screen bg-white">
      <div className="max-w-md mx-auto relative min-h-screen flex flex-col">
        {/* Screen Content */}
        <div className="flex-1 overflow-auto">
          {currentScreen === 'splash' && <SplashScreen />}
          {currentScreen === 'home' && <HomeScreen navigateTo={navigateTo} />}
          {currentScreen === 'live' && <LiveMonitorScreen navigateTo={navigateTo} />}
          {currentScreen === 'violations' && <ViolationsListScreen navigateTo={navigateTo} />}
          {currentScreen === 'violation-detail' && selectedViolation && (
            <ViolationDetailScreen violation={selectedViolation} navigateTo={navigateTo} />
          )}
          {currentScreen === 'score' && <DriverScoreScreen navigateTo={navigateTo} />}
          {currentScreen === 'payment-method' && (
            <PaymentMethodScreen amount={paymentAmount} navigateTo={navigateTo} />
          )}
          {currentScreen === 'payment-form' && (
            <PaymentFormScreen amount={paymentAmount} navigateTo={navigateTo} />
          )}
          {currentScreen === 'payment-success' && (
            <PaymentSuccessScreen amount={paymentAmount} navigateTo={navigateTo} />
          )}
          {currentScreen === 'settings' && <SettingsScreen navigateTo={navigateTo} />}
        </div>

        {/* Bottom Navigation */}
        {showNavigation && (
          <BottomNavigation currentScreen={currentScreen} navigateTo={navigateTo} />
        )}
      </div>
    </div>
  );
}

export default App;
