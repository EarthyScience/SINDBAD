function [f, fe, fx, s, d, p] = dyna_cAlloc_gsi(f, fe, fx, s, d, p, info, tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the fraction of NPP that is allocated to the
    % different plant organs. In this case, the allocation is dynamic in time
    % according to temperature, water and radiation stressors computed from GSI approach.
    %
    % Inputs:
    %   - d.cAllocfwSoil.fW:    water stressors for carbon allocation
    %   - d.cAllocfwSoil.fT:    temperature stressors for carbon allocation
    %   - d.cAllocfRad.fR:      radiation stressors for carbo allocation
    %
    % Outputs:
    %   - s.cd.cAlloc: the fraction of NPP that is allocated to the different plant organs
    %
    % Modifies:
    %   - s.cd.cAlloc
    %
    % References:
    %   - Jolly, William M., Ramakrishna Nemani, and Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 (2005): 619-632.
    %   - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K (2014) Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
    %   - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).
    %     Codominant water control on global interannual variability and trends in land surface phenology and greenness.
    %
    % Created by:
    %   - ncarvalhais and sbesnard
    % Notes:
    % Check if we can partition C to leaf and wood constrained by interception of light.
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % allocation to root, wood and leaf
    cf2.cVegLeaf = d.cAllocfwSoil.fW(:, tix) ./ (d.cAllocfwSoil.fW(:, tix) + d.cAllocfTsoil.fT(:, tix)) ./ 2;
    cf2.cVegWood = d.cAllocfwSoil.fW(:, tix) ./ (d.cAllocfwSoil.fW(:, tix) + d.cAllocfTsoil.fT(:, tix)) ./ 2;
    cf2.cVegRoot = d.cAllocfTsoil.fT(:, tix) ./ (d.cAllocfwSoil.fW(:, tix) + d.cAllocfTsoil.fT(:, tix));

    % distribute the allocation according to pools
    %     cpNames = {'cVegRoot', 'cVegWood', 'cVegLeaf'};

    for cpN = 1:numel(s.cd.p_cAlloc_cpNames)
        cpName = s.cd.p_cAlloc_cpNames(cpN);
        zixVec = s.cd.p_cAlloc_zixVecs{cpN};
        N = numel(zixVec);

        for zix = zixVec
            s.cd.cAlloc(:, zix) = cf2.(cpName) ./ N;
        end

    end

    % cpNames = ["cVegRoot", "cVegWood", "cVegLeaf"];

    % for cpName =cpNames
    %     zixVec = info.tem.model.variables.states.c.zix.(cpName);
    %     N = numel(zixVec);

    %     for zix = zixVec
    %         s.cd.cAlloc(:, zix) = cf2.(cpName) ./ N;
    %     end

    % end

end
