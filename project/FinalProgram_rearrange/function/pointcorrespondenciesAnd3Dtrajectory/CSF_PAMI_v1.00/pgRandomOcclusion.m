
function VALID = pgRandomOcclusion( W, rank_W, miss_perc )

siz = size(W);
siz(1) = siz(1) / 2;   % for SFM

% each column must have at least "rank_W" non-missing entries
miss_perc = min( miss_perc, 1 - rank_W/siz(1) );     % upper bound on missing data
numPick = round( (1 - miss_perc)*siz(1)*siz(2) - rank_W*siz(2) );

% (1) randomly pick rank_W values in each column
VALID = false(siz);
for j = 1:siz(2)
   mask = randperm( siz(1) );
   VALID(mask(1:rank_W),j) = true;
end

% (2) select over remaining entries
set = find( ~VALID(:) );
set = set( randperm(numel(set)) );
VALID( set(1:numPick) ) = true;

% (3) duplicate row-masks for SFM problem
rows = [ 1:siz(1) ; 1:siz(1) ];
VALID = VALID( rows(:), : );
