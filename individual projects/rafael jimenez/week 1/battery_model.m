function [V_batt, I_batt, SOC] = battery_model(P_elec, datBat, dt)
persistent soc
if isempty(soc)
    soc = 1; % start full
end

Voc = interp1(datBat.SOC, datBat.OCV, soc, 'linear','extrap');
I_batt = P_elec / (Voc * datBat.numSeries);
V_batt = Voc * datBat.numSeries - I_batt * datBat.Rint * datBat.numSeries;

soc = max(0, min(1, soc - (I_batt * dt / 3600) / datBat.C));
SOC = soc;
end
