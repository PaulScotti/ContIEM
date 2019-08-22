% Searchlight -- create your spheres of interest

vox_seeds = [];
for a = 11:10:162
    for b = 32:10:180
        for c = 40:10:162
            vox_seeds = [vox_seeds; a,b,c];
        end
    end
end
for v = 1:size(vox_seeds,1)
    [X,Y,Z] = sphere(25);
    X = normalize(X,'range',[0,25]);
    X = round(X + vox_seeds(v,1));
    Y = normalize(Y,'range',[0,25]);
    Y = round(Y + vox_seeds(v,2));
    Z = normalize(Z,'range',[0,25]);
    Z = round(Z + vox_seeds(v,3));
end