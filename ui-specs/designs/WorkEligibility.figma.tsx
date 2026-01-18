import { GlassCard } from './GlassCard';
import { PrimaryActionButton } from './PrimaryActionButton';
import { SectionHeader } from './SectionHeader';

export function WorkEligibility() {
  return (
    <div className="min-h-screen bg-black text-white overflow-y-auto">
      {/* Safe area padding for notch/Dynamic Island */}
      <div className="pt-6 px-4 pb-8">
        
        {/* System Notice - Expired Credential Alert */}
        <div className="bg-[rgba(255,149,0,0.2)] border border-[rgba(255,149,0,0.3)] rounded-xl p-4 mb-6">
          <div className="flex items-start gap-2">
            <span className="text-sm">⚠️</span>
            <div>
              <p className="text-sm text-white">Credential expired</p>
              <p className="text-xs text-[#8E8E93] mt-1">
                Expired credentials remove access immediately
              </p>
            </div>
          </div>
        </div>

        {/* SECTION 1: Eligibility Summary */}
        <div className="mb-6">
          <h1 className="text-[28px] font-bold text-white mb-4">Work Eligibility</h1>
          
          <GlassCard>
            <div className="space-y-4">
              {/* Current Trust Tier */}
              <div>
                <div className="text-4xl font-bold text-white">Tier 2</div>
                <div className="text-xs text-[#8E8E93]">Current Trust Tier</div>
              </div>

              {/* Active Risk Clearance */}
              <div>
                <div className="text-sm text-[#8E8E93] mb-2">Active Risk Clearance</div>
                <div className="inline-block bg-[rgba(52,199,89,0.2)] border border-[rgba(52,199,89,0.4)] rounded-md px-3 py-1">
                  <span className="text-sm text-[#34C759]">Medium</span>
                </div>
              </div>

              {/* Work Location */}
              <div>
                <div className="text-sm text-[#8E8E93]">Work Location</div>
                <div className="text-xl font-bold text-white">WA</div>
              </div>

              {/* Two-column eligibility list */}
              <div className="grid grid-cols-2 gap-4 pt-4 border-t border-[rgba(255,255,255,0.1)]">
                <div>
                  <div className="text-sm text-white font-bold mb-2">You're eligible for:</div>
                  <ul className="space-y-1">
                    <li className="text-xs text-[#8E8E93] flex items-start">
                      <span className="mr-2">•</span>
                      <span>Low-risk gigs</span>
                    </li>
                    <li className="text-xs text-[#8E8E93] flex items-start">
                      <span className="mr-2">•</span>
                      <span>Medium-risk appliance installs</span>
                    </li>
                  </ul>
                </div>
                <div>
                  <div className="text-sm text-white font-bold mb-2">Not eligible for:</div>
                  <ul className="space-y-1">
                    <li className="text-xs text-[#8E8E93] flex items-start">
                      <span className="mr-2">•</span>
                      <span>Electrical — license required</span>
                    </li>
                    <li className="text-xs text-[#8E8E93] flex items-start">
                      <span className="mr-2">•</span>
                      <span>In-home care — background check required</span>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </GlassCard>
        </div>

        {/* SECTION 2: Verified Trades */}
        <div className="mb-6">
          <SectionHeader>Verified Trades</SectionHeader>
          
          <div className="space-y-4">
            {/* NOT VERIFIED State */}
            <GlassCard>
              <div className="flex items-start gap-3">
                <span className="text-xl">❌</span>
                <div className="flex-1">
                  <div className="text-sm text-white">Plumber</div>
                  <div className="text-xs text-[#8E8E93]">Not verified</div>
                </div>
              </div>
              <div className="mt-3">
                <PrimaryActionButton disabled>Verify license</PrimaryActionButton>
              </div>
            </GlassCard>

            {/* PENDING State */}
            <GlassCard>
              <div className="flex items-start gap-3">
                <span className="text-xl">⏳</span>
                <div className="flex-1">
                  <div className="text-sm text-white">HVAC Technician</div>
                  <div className="text-xs text-[#8E8E93]">Verification in progress</div>
                  <div className="text-xs text-[#8E8E93] italic mt-1">
                    This usually takes under 24 hours
                  </div>
                </div>
              </div>
            </GlassCard>

            {/* VERIFIED State */}
            <GlassCard>
              <div className="flex items-start gap-3">
                <span className="text-xl">✅</span>
                <div className="flex-1">
                  <div className="text-sm text-white font-bold">Electrician</div>
                  <div className="text-xs text-[#8E8E93]">WA</div>
                  <div className="text-xs text-[#8E8E93]">Expires: May 1, 2026</div>
                </div>
              </div>
            </GlassCard>
          </div>
        </div>

        {/* SECTION 3: Insurance Section (Conditional - shown because user has verified trade) */}
        <div className="mb-6">
          <SectionHeader>Insurance</SectionHeader>
          
          <div className="space-y-4">
            {/* EXPIRED State */}
            <GlassCard>
              <div className="flex items-start gap-3">
                <span className="text-xl">⚠️</span>
                <div className="flex-1">
                  <div className="text-sm text-white">General Liability Insurance</div>
                  <div className="text-xs text-[#FF9500]">Expired</div>
                  <div className="text-xs text-[#8E8E93]">Expired: December 15, 2025</div>
                </div>
              </div>
              <div className="mt-3">
                <PrimaryActionButton>Renew insurance</PrimaryActionButton>
              </div>
            </GlassCard>
          </div>
        </div>

        {/* SECTION 4: Background Checks (Conditional - shown if opted into critical tasks) */}
        <div className="mb-6">
          <SectionHeader>Background Checks</SectionHeader>
          
          <div className="space-y-4">
            {/* VERIFIED State */}
            <GlassCard>
              <div className="flex items-start gap-3">
                <span className="text-xl">✅</span>
                <div className="flex-1">
                  <div className="text-sm text-white font-bold">Criminal Background Check</div>
                  <div className="text-xs text-[#8E8E93]">Verified</div>
                  <div className="text-xs text-[#8E8E93]">Expires: August 10, 2026</div>
                </div>
              </div>
            </GlassCard>
          </div>
        </div>

        {/* SECTION 5: Upgrade Opportunities (Computed Display Only) */}
        <div className="mb-6">
          <GlassCard className="border-[rgba(10,132,255,0.3)]">
            <div className="flex items-start gap-3">
              <span className="text-2xl">💼</span>
              <div className="flex-1">
                <div className="text-sm text-white font-bold">Verify Plumber License</div>
                <div className="text-xs text-[#8E8E93] mt-1">
                  Unlocks 7 active gigs near you
                </div>
                <div className="text-xs text-[#8E8E93] mt-1">
                  Average payout: $180
                </div>
              </div>
            </div>
            <div className="mt-3">
              <PrimaryActionButton>Verify license</PrimaryActionButton>
            </div>
          </GlassCard>
        </div>

      </div>
    </div>
  );
}
