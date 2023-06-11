KEY="samael"
KEY2="samael2"
CHAINID="highbury_710-1"
MONIKER="samael"
KEYRING="test"
KEYALGO="secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# Reinstall daemon
rm -rf ~/.fury*
make install

# Set client config
fury config keyring-backend $KEYRING
fury config chain-id $CHAINID

# if $KEY exists it should be deleted
fury keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO
fury keys add $KEY2 --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Black (Moniker can be anything, chain-id must be an integer)
fury init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to ufury
cat $HOME/.fury/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ufury"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json
cat $HOME/.fury/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ufury"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json
cat $HOME/.fury/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ufury"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json
cat $HOME/.fury/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="ufury"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json
cat $HOME/.fury/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="ufury"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json

# Change voting params so that submitted proposals pass immediately for testing
cat $HOME/.fury/config/genesis.json| jq '.app_state.gov.voting_params.voting_period="3000s"' > $HOME/.fury/config/tmp_genesis.json && mv $HOME/.fury/config/tmp_genesis.json $HOME/.fury/config/genesis.json


# disable produce empty block
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.fury/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.fury/config/config.toml
fi

if [[ $1 == "pending" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.fury/config/config.toml
      sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.fury/config/config.toml
  else
      sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.fury/config/config.toml
      sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.fury/config/config.toml
  fi
fi

# Allocate genesis accounts (cosmos formatted addresses)
fury add-genesis-account $KEY 200000000000ufury --keyring-backend $KEYRING

                              
# Investors
fury add-genesis-account blackaf1jl2zcz32npjgs88vd60xv5qan5rtzh4xc3m6uu 9375000000000ufury --keyring-backend test				
fury add-genesis-account blackaf19umlsn9fc3ytfe9s3l9dez4z2ujjljqjnneunw 3125000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1t0lzffhd5yhclj4pmhxp4h82nxfr08c5xmyql9 825000000000ufury --keyring-backend test				
fury add-genesis-account blackaf120fza5vukwmaksphtqesrh4kqxf8er6e6f5vrv 4455000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1d03ppywn369qzajeuqs0dge29rchxteazqgzku 825000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1e6m3jymsgetz5vyvkvujejqufanpq8mgnuttwk 2747500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1cwk4s0jtvt69mawaqsay2a9h20cgqd9hk9j3q7 3238333000000ufury --keyring-backend test				
fury add-genesis-account blackaf1f02wg3dawqdwjv7ak7e6vh2u6sjf5s26gf4syd 2722500000000ufury --keyring-backend test				
fury add-genesis-account blackaf136qxshkaf78ucuff4kdc8srw73k2x0adjld5un 447856500000ufury --keyring-backend test				
fury add-genesis-account blackaf1al3k6rd4u550gcvfwd7akl032su2y2vtstyk3x 127284750000ufury --keyring-backend test				
fury add-genesis-account blackaf1526zhyrd8fzdvzayct9yfnspsdp9uuqhx0r63e 555000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1jhpwxpadlx8ax429ljm5rrqm2pse4sgf73gg4q 424284750000ufury --keyring-backend test				
fury add-genesis-account blackaf1es9fu48yxwd9jdweaykjaf0fr7usw3x0u33pgy 165000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1as8j8qhexvsc3sy0gxrfajuuggwar45c4503xm 99000000000ufury --keyring-backend test				
fury add-genesis-account blackaf158343p7g7qlw76ph5dzvtvk5tztegz3g782e2h 132000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1rq048x4ducr9nqze48g55x0q57e8lthx3ketrr 136713750000ufury --keyring-backend test				
fury add-genesis-account blackaf1wknw5glel2jekejuehn4auvfs7dhqf6ztchnns 66000000000ufury --keyring-backend test				
fury add-genesis-account blackaf14z8wsgf807e3hxuny5laaxtn0ytvcj9qyxe77e 330000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1czemphdmk0j9vn6gspj454p24rs5jz4gal0jpr 136713750000ufury --keyring-backend test				
fury add-genesis-account blackaf1hcgqp24ps3n09pk4ugu7tscj72q25r8r44yel0 183856500000ufury --keyring-backend test				
fury add-genesis-account blackaf1gyvgpngr3saypgdud0etzj74q56vy97s4w2e9x 113142000000ufury --keyring-backend test				
fury add-genesis-account blackaf15wcg9d228whk85zf4rde7nypn09htc2gxnpg7n 183856500000ufury --keyring-backend test				
fury add-genesis-account blackaf10le9zwrp6x9t6xcg4ws2j8rsvggvktajwq5rwd 282856500000ufury --keyring-backend test				
fury add-genesis-account blackaf1ssfpxgkzt4yj0unmzx0cmrx6mhm5kl0ggx54e7 495000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1w33lkcauxeyrq8nn3f6h9cgncxuxdrzmsja8dh 1060713750000ufury --keyring-backend test				
fury add-genesis-account blackaf1nthsvkmqdl4qmeg0qh40s0jrjpquncdy547jxk 3000000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1kndgwd8vtn38zhq5ae8yjm5ez7sz3xy5jc50wx 157500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1y0lufpa3yfnwrjk5lfz3zcl9hq6stmdhrxfdrs 353571750000ufury --keyring-backend test				
fury add-genesis-account blackaf1ejtqghtlhauyqag8xphnkltvqjuxwl5std30l0 353571000000ufury --keyring-backend test			
fury add-genesis-account blackaf1t2rkh00d000qzlyj2l2l8z5hy34a3e739muemf 235713750000ufury --keyring-backend test				
fury add-genesis-account blackaf129kdy7qdk5r4qgrenqdd6ftjjuvcc3hqjehcqr 336284750000ufury --keyring-backend test				
fury add-genesis-account blackaf1vum9yv6gtd54kpgdhd37p5z097ngphlfvtxere 235713750000ufury --keyring-backend test				
fury add-genesis-account blackaf1xeve8vkkltsd9uzaqya78ywtspyc35hrwd58yr 94293750000ufury --keyring-backend test				
fury add-genesis-account blackaf1lldkcxprlhqknnal3w0wp2fe0mlhyzdchmxmh0 1178571750000ufury --keyring-backend test				
fury add-genesis-account blackaf1tz80tk5295jafft5njnvvxgnvcf63y3vqvgle2 471429000000ufury --keyring-backend test				
fury add-genesis-account blackaf1clwgp88d7aq2nhk5mmwk2w82t67n3fgk30nu9t 154286250000ufury --keyring-backend test				
fury add-genesis-account blackaf17w74x9vrqq4a338ssh9y9r4m9s3f6zefunu9nc 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf1kah8qvju0h5g0nslsfhvznrsw0jrhnry7ss5wh 428571750000ufury --keyring-backend test				
fury add-genesis-account blackaf1d4ulqc7y3pqe5lxdwv0sl7cd9qnkjtur0fzf6e 5357143500000ufury --keyring-backend test				
fury add-genesis-account blackaf19k85gsahz45qr86gn5t0ym7zac8nlm6v9tvsc0 107143500000ufury --keyring-backend test				
fury add-genesis-account blackaf1qws9l50tvnmfx0hrek9500dzygv92rj40vh39g 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf14zeskm5s4yz75fd4r70m37u37wfzt9lpc9ztjh 28929000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zy2usgrg4ywh7e3j8qychvxarp4y5shfq4fnpn 21429000000ufury --keyring-backend test				
fury add-genesis-account blackaf1qksggyhumezsdmeelqrvhdyh2n6nshmud9sx97 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf1vmk950mvwakjef3qjjpcz9f28x3ah3q84avg56 42857250000ufury --keyring-backend test				
fury add-genesis-account blackaf1k03n5tcj6f7d6zkjp3xvl8h6hp05vprlj9kme5 642857250000ufury --keyring-backend test				
fury add-genesis-account blackaf18zmgjqxa6d274achj6dmkdddys4453ta9f9x46 642857250000ufury --keyring-backend test				
fury add-genesis-account blackaf1e5ag4a5wlckwzlz4wu87p6nxjp427zpm6gxy2q 428572500000ufury --keyring-backend test				
fury add-genesis-account blackaf1tluyekggnce4js7usrs0xk06528vg99rljav30 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf162cxa76zpvag4a05da0yhu69awfy35w8rngtzu 364286250000ufury --keyring-backend test				
fury add-genesis-account blackaf1azg0gpgatmzr60mzya9d774eude263ef57nhgu 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf1kfr4wznhwelzhal8gc8es67tcx4g4tsyvndz6m 214286250000ufury --keyring-backend test				
fury add-genesis-account blackaf1qvesqkksz3nyrys5gvlryfj8zv90pz9qxq9te5 642857250000ufury --keyring-backend test				
fury add-genesis-account blackaf1kml5p8et0j7zhqptxla74nf0gfsumcy7wsv4kk 2142857250000ufury --keyring-backend test				
fury add-genesis-account blackaf15y4xh9xj2lm9ll4usturv4qdugr5t0gnnfant6 642857250000ufury --keyring-backend test				
fury add-genesis-account blackaf17xdjy3t0dtqhxzlk7dxmm32j7u7krfn3jnt43z 428571000000ufury --keyring-backend test				
fury add-genesis-account blackaf12l4ehyq5qzsmvapa5a8ls9sr65q8yf08mjtfrp 535714500000ufury --keyring-backend test				
fury add-genesis-account blackaf1fs2yal2cs89mqnn389ap3rh5z842llfhnyxhls 321428250000ufury --keyring-backend test				
fury add-genesis-account blackaf1mhv5w6up9ltlwe7ekgfpjhd0upn4f7umej9wzl 964285500000ufury --keyring-backend test				
fury add-genesis-account blackaf1vc8772tklysj5ryaz2s0kx66k4fw3x3y754y2p 105000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ja4jpkvf9tw5w9pt3futxq6hxs5lwf843upy73 105000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1l4ml9eklv84zpm0968jt4hezwaymwr6kjv37f5 81750000000ufury --keyring-backend test				
fury add-genesis-account blackaf147ck7dxylz7d4mrjw7r6g2sdx6j3vmds4qewl0 70500000000ufury --keyring-backend test				
fury add-genesis-account blackaf12zquqgw5ejaxphfeqh3ycduuwmvpennkflvuju 79500000000ufury --keyring-backend test				
fury add-genesis-account blackaf152a6ympm8pmpmn3z8rxka6gdj96ssu7rv324lu 16815750000ufury --keyring-backend test				
fury add-genesis-account blackaf1vdl5mwqkpepvsacckr50m8eyk80hqp23jy66d2 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf17u9m4sgfg3ahdenacfq4j6uzm4qucf5ux2kvg4 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1hyxea0xa08wv4y30v5q9g2jwls8cgdk6g0rt89 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1mz6dr3yzdvnnaeg3e6mgvuwnluq63ep3n6ughy 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1r796wq2hn0k7yf8kcqrmlxqmf3ys4pdyeg3pqv 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1uxylhand5q6j3xg2qxwzl9hez7a20j8atutcky 7500000000ufury --keyring-backend test				
fury add-genesis-account blackaf1r76xl88z8payyt0zx333c5v5hh5rjp2aqktnyh 7500000000ufury --keyring-backend test					
fury add-genesis-account blackaf1ya8d8u6assqy0wyvdhg9kuud69z9gkjp0l2f2p 437500000000ufury --keyring-backend test				

# Blackdragon

fury add-genesis-account blackaf1797slhn49lfmgn42vwjh6c6nrxq7k34nqa6kdv 47771000000ufury --keyring-backend test				
fury add-genesis-account blackaf10h7ln638jkn55h5wfk2enyszhtv3nf3hjd7xpf 36505000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wexz2r5g6rsphka9qqvsqsaalc4shw7h0v94xw 68741000000ufury --keyring-backend test				
fury add-genesis-account blackaf13pqlfc4wesmfwg0mh224khsy9nrek2e34uk9ld 36457000000ufury --keyring-backend test				
fury add-genesis-account blackaf1gwqvuzl4xwfwaxacygqkrux4dpgsl4duavv2pl 28662000000ufury --keyring-backend test				
fury add-genesis-account blackaf1kusnsv5evmtujdvr2hvr5chs9aen0gwyv4r36d 50286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1dkmehpuc582evv2uq70kt0jptpehu3yr4xag2q 34069000000ufury --keyring-backend test				
fury add-genesis-account blackaf122nwk3z6e4yeh4aj4xad3jmjy38h8jw80aalx6 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf14lkxkdlrmvv732vhygeev95tmerxec6ahytewr 75429000000ufury --keyring-backend test				
fury add-genesis-account blackaf13fdh9uey7t0hxvg825gdfdx346z7wsq2fumrt8 365269000000ufury --keyring-backend test				
fury add-genesis-account blackaf1nrye3zfvs7l438n6l56avnnzm6f00me8geeh99 86185000000ufury --keyring-backend test				
fury add-genesis-account blackaf1q97lwrj563g8ccfm6kl9zxndf860v60eny0zqr 18254000000ufury --keyring-backend test				
fury add-genesis-account blackaf17mrjke5ra03hqnh7tlk265xlj2asz9laxe4f89 50286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1q84cgldq5wf3am3tfuz2lzzx2azala64g3znp6 50286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1unwqjxcwv95jfu3nt89ky8zqh39xpqvwndcr2f 18229000000ufury --keyring-backend test				
fury add-genesis-account blackaf17parq8q75sr2cejrnrurtt7emfrc35a035aps6 9030000000ufury --keyring-backend test				
fury add-genesis-account blackaf199jfnv587vy4f63gn6t2t4dae42prk24t65dt0 50286000000ufury --keyring-backend test				
fury add-genesis-account blackaf154sksmrrrveqcdavk4ugyxmwlmdepdg0r9qfhq 50310000000ufury --keyring-backend test				
fury add-genesis-account blackaf1q5cddxnk7yqxc4fjfmnpxhygkcl3uw6slxuaxr 93629000000ufury --keyring-backend test				
fury add-genesis-account blackaf1lw0ruyesylglsu6m7dhefw4vfh8l8qweulqay6 12572000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zm3z7dd4ee8vfxu82lfmma4wmcnt3z87s8qk66 13904000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wackempnenwpzkywav6hnmdckqmthv30uuweyu 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1cnzy6g0vet3ykdhk2xgvkvc350d3gke4fuvmct 182527000000ufury --keyring-backend test				
fury add-genesis-account blackaf1r9764rmspkpy0qxx5myxq0kz90dukjna4a2kh7 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1nk2rycxdgl5gxtd0hpncprwfp0lzeafwuth6yd 23584000000ufury --keyring-backend test				
fury add-genesis-account blackaf1nhhvjlq376f4gz6jvptsgv665vr3ss4q6q70fr 37714000000ufury --keyring-backend test				
fury add-genesis-account blackaf16kgjjvhq9s07l639ylpc6sfp4cp6ze8hgjglv2 10057000000ufury --keyring-backend test				
fury add-genesis-account blackaf1aqqskedu4zgmjqhpztjqzd7g8sfyzya203r9xc 37714000000ufury --keyring-backend test				
fury add-genesis-account blackaf1fdgys6er5ak4syqgvc8uswcedjwknh6qw53nqa 35784000000ufury --keyring-backend test				
fury add-genesis-account blackaf1e5pkymea4jlcmnzvrycc97jfhdzcvpd3pzz8ar 75442000000ufury --keyring-backend test				
fury add-genesis-account blackaf18rp5vnjsswdazjvrdy2lj4cass9z29h5wknu4z 11191000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ty8uvzrhy5taa4auc9h9c02x0zfugu0jfge7y3 252132000000ufury --keyring-backend test				
fury add-genesis-account blackaf1dn8yt2pe62a9nz964vmj2pwreljxehxcgya6zr 251429000000ufury --keyring-backend test				
fury add-genesis-account blackaf16qt98ac36dtaaxr7axu67z68ue8pjpdcjvu2cc 6311000000ufury --keyring-backend test				
fury add-genesis-account blackaf1hwapfpynu0evhdvhnge6929eu0hrpj5p0e3nqa 106818000000ufury --keyring-backend test				
fury add-genesis-account blackaf145wnzde7ak68zm49yhgyc0apxpj6gwjex52dc9 20251000000ufury --keyring-backend test				
fury add-genesis-account blackaf12u9t55uxfmkd8c4mzpeatvnjmyvuj5gejfhx6v 189306000000ufury --keyring-backend test				
fury add-genesis-account blackaf1xsmep764kqh3fq4rq7yp7t3qgnjycp9lgnnpnv 56922000000ufury --keyring-backend test				
fury add-genesis-account blackaf16k7xarsvqf7vv0qhu520rmarpt40g6jtr64v6t 377143000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zejc6j533jjgzj64munsps257sa95282m9pqkp 22880000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wypy5jw7xz0lkrz3ky538vr4e7seuvs9pj77sz 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf19frtd7huz6zrefnz3zl64z6q8r9wkt3pulc88c 18271000000ufury --keyring-backend test				
fury add-genesis-account blackaf1lqseqddsce3yu5wa7atf8feqqfyn3lcmfa6fux 238593000000ufury --keyring-backend test				
fury add-genesis-account blackaf1elhw3cct0jgxvf2tw5yrrkc6u02shg8z43le48 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf19rn5vwga60kun3j38taxd26cm7lelgda40u37t 18382000000ufury --keyring-backend test				
fury add-genesis-account blackaf1htxf0fcfmyxyw8stjw38jz2s3muh3q6y3al9nz 18304000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ymtq3eyk2s6q44phkqv8k35jqve52d0z2ld4dd 25167000000ufury --keyring-backend test				
fury add-genesis-account blackaf169qmwy36jkhfzjdft3ptqqmj2zgkc3tvx07qp2 75429000000ufury --keyring-backend test				
fury add-genesis-account blackaf1w6pktm54f5zgq032xxacc3ylme98t560665dpx 12572000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zjvwyksf9vnk0dwxx3n8m9xlw6pglnf0uhnkyd 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zurjhfcc5365dsy58unk6rnh9nltfsqqj4dvmk 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf134fwqahtfrg0zfr8x2su46fmrwme5mzww847l0 15614000000ufury --keyring-backend test				
fury add-genesis-account blackaf1mgmcztfm8vvmfdmtlzk3n523vqm275j7xhu22d 20647000000ufury --keyring-backend test				
fury add-genesis-account blackaf1r0afwj9krzmwsadjm6l6y7mlnq6l7px06vda6n 14120000000ufury --keyring-backend test				
fury add-genesis-account blackaf1acd5nzld4f3c268cax90lk6he7m2w5mlw8tgyf 25142000000ufury --keyring-backend test				
fury add-genesis-account blackaf1lmw6wtyk0w6zg6jh05z4t5l7amvsalapq05cr3 50290000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wxvs6du63g8nmm5jpd3lzgwl6mqv0je9ug7q7c 18857000000ufury --keyring-backend test				
fury add-genesis-account blackaf17zjpts3cd35tesmwrunkynygyw7fuamsu4cx33 11943000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ygqgkduw25g5uezflw4gnsm4n2yvawkm9r056r 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1zjydgdhd8uk4u29tq2e68j7kmqxrk3vse8tdtu 18253000000ufury --keyring-backend test				
fury add-genesis-account blackaf1x60g2u04z7jzdnjf3znfdcxa9ut5kufqtrcywy 505555000000ufury --keyring-backend test				
fury add-genesis-account blackaf15tmdfth2kmmaedag9sk7j0nw4herj39aswyjgy 226286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1r4w3ae4vuyatckn8pahvexl4kpvmndreah5hht 10057000000ufury --keyring-backend test				
fury add-genesis-account blackaf19j5upjz972gh24890tn6mpf4gzqdk09an7esru 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1cg3e7sfxkunmwgfsrqj3caju9aheuzlz094y2p 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ca6vj94jtn5v57prr826ncskrm0reatev73ame 104278000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ltk76ycjtz05j7ww7yznrr5cn5kz58zayas68c 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf1y26ufq905uy0s27ftujamqm5y8gdys8dcrg0lu 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf122phsq2td9x3cv9pwszse3f69smfhhnc8lc6gu 8800000000ufury --keyring-backend test				
fury add-genesis-account blackaf1vv6rsgxqh4hyxtt6dt4rmv4a93n7amjtpqydun 19038000000ufury --keyring-backend test				
fury add-genesis-account blackaf14cyvvq5nptglnjy2hg9ky6r26349v73nau2te7 52800000000ufury --keyring-backend test				
fury add-genesis-account blackaf1clseqnswluj79tzpng60sqhy3nf7pz0hcphfqq 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf1vvgh02zkh4qf9hydk0walw9nyx4udemr8k894f 31378000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ecm2vqdexfqy6kfpwdxxpl37vy289pmhnkkmwt 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1je5w89kn456ctj7fd3y4w4rf3f7klj6xhxm3pn 50309000000ufury --keyring-backend test				
fury add-genesis-account blackaf1yuqgnfuavv2wf6lpsr0w6wqed9d7grza7g42wr 53453000000ufury --keyring-backend test					
fury add-genesis-account blackaf10d4udrt2md9dzeqfaytkdhcd9utsmvxkmx0tpw 8800000000ufury --keyring-backend test				
fury add-genesis-account blackaf108gy2rzhx27jj96argmgpesvlj9ur6k8lteu7j 18231000000ufury --keyring-backend test				
fury add-genesis-account blackaf1le8x5sn43nxn0sz5vuze509sea70sc6jsje2ys 8800000000ufury --keyring-backend test				
fury add-genesis-account blackaf1xvf0jjf9vkqz40rdlmm67cfhlzcwu520zpaqam 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf1tu4g3fpx9282y2ejt6zv6m9geq97mym52dc0gf 13577000000ufury --keyring-backend test				
fury add-genesis-account blackaf168q4t94pxq97fy8vqenc6fx3znc7p8fe3kvgl8 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1fzd65shhhkl7d3g2f5377fufd4k9adn2494uy7 30171000000ufury --keyring-backend test				
fury add-genesis-account blackaf1yafjl2890r3gn38dc7ksp5r6vnfmy8udtm7zja 209480000000ufury --keyring-backend test				
fury add-genesis-account blackaf1l52awqe7p8r9mmpm27c5avywt9urqdpd3547xu 8800000000ufury --keyring-backend test				
fury add-genesis-account blackaf1fqtp07xjqwx2my5n42vcwufu6hc70zw40v9plg 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf18ws6vgl6w84qcs0wncup25va9ze88852e3jdm6 35200000000ufury --keyring-backend test				
fury add-genesis-account blackaf1vu2p0zta4lg4fsdv777ugmajyvqrcslj0x3d98 10057000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wltvdtjdnpe6uh5adg0m7ydy8cle8wwyzmn752 25164000000ufury --keyring-backend test				
fury add-genesis-account blackaf12m90u3cetug08frawfu0p6jd96s354xd24ftz0 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf1pm350tzyg0rvvma7e43ezz729yxa5ljuzpw5me 232246000000ufury --keyring-backend test				
fury add-genesis-account blackaf1pm3pva53gv4nnhvmduuh322pjmxv98t67shetp 25160000000ufury --keyring-backend test				
fury add-genesis-account blackaf1y2l7gnylqw3yp6u52tfgxuk0klx5uyms4ddg2c 100571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1gyv42pg4j790wlqt5muge7pe9d9xdw7r0dd06v 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1klfd2u30qakx8qeqcw0xdcc3p3djq7htlgc6gl 49715000000ufury --keyring-backend test				
fury add-genesis-account blackaf145tk8ry9gzmr5jyn96pznfanadxqrvmpmgwap9 36489000000ufury --keyring-backend test				
fury add-genesis-account blackaf17tc5dxkejps3adusaluzu7xn9jmg7qmwama68v 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf170k6xd7atru2uzmnqy345gyr5xcw8ke74ddywg 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1xe7fkxfkl882uua6zyjadv296umtxdykluhdyf 10057000000ufury --keyring-backend test				
fury add-genesis-account blackaf1kxyzha73fnrzd8sf3a44dnl89whrvkdyaec5gl 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf14z20ghpgxayvll6ppz9m4pxp939tx2uzmnvsp4 25143000000ufury --keyring-backend test				
fury add-genesis-account blackaf1cuazcgw2m3x5r9gkyusrugn50wee4t9p39ltvu 13899000000ufury --keyring-backend test				
fury add-genesis-account blackaf1rd4xs8xvggyrejjsemrjs9vxs4h6hdgq7kyf2v 10057000000ufury --keyring-backend test				
fury add-genesis-account blackaf1ahrzs5snug646umdeeqrw6dap6ex0mnt6qeseq 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf10qrkeqjjdyx7zsfdx9cszj89xjph2ctm7wsuak 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1wa3lf2p624khztlrcz8kuh3sq8sfret2m2fg66 17600000000ufury --keyring-backend test				
fury add-genesis-account blackaf1u7wn3x6zphmuh0yuld7jly72725d4re6d52xlh 176000000000ufury --keyring-backend test				
fury add-genesis-account blackaf1yrd99my556rvsfppfm96z6v7n439rr0x4tlcpu 22629000000ufury --keyring-backend test				
fury add-genesis-account blackaf14lxhx09fyemu9lw46c9m9jk63cg6u8wd66eu5a 23157000000ufury --keyring-backend test				
fury add-genesis-account blackaf14c4ldwt8grnp6p9eq8kumw9uq63h8k46tmuwg6 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1hqgete6pcc2v6zsp6kl4dr892wwgdkensmyj2h 75429000000ufury --keyring-backend test				
fury add-genesis-account blackaf16wxtrzta2c9pnr3gxq7vax48kvhtw32lvhzlc2 8800000000ufury --keyring-backend test				
fury add-genesis-account blackaf1pzt8ykkt4puf0xef4h0xgf4watffgp40qqls6t 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1le6qxteptv3cc29cyt2clm6zmzmn4x579wcsgu 15086000000ufury --keyring-backend test				
fury add-genesis-account blackaf1d727nqk2j0k8pyd7qt9s4yh7x559r04a4uevpa 6286000000ufury --keyring-backend test				
fury add-genesis-account blackaf130s6vp9xk0h2fffcec0km06qp2nkdqjlevyuq7 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf16uru2e0ja9j9fppg7at7s0pm0en5sr3rtfp59q 50286000000ufury --keyring-backend test				
fury add-genesis-account blackaf1fsezzt4rj6cm0my6z3f9hj3scvrkw5nsyt27xm 7543000000ufury --keyring-backend test				
fury add-genesis-account blackaf12dlda2x3fm6rqyplnk2sdemspcc9gwdj02yf5n 12571000000ufury --keyring-backend test				
fury add-genesis-account blackaf1w4v0tjfpfqrncl3mh8ezmceyjfjnnukzz0h082 12729000000ufury --keyring-backend test				
   
# Update total supply with claim values
#validators_supply=$(cat $HOME/.fury/config/genesis.json | jq -r '.app_state["bank"]["supply"][0]["amount"]')
# Bc is required to add this big numbers
# total_supply=$(bc <<< "$amount_to_claim+$validators_supply")

echo $KEYRING
echo $KEY
# Sign genesis transaction
fury gentx $KEY 2000000000ufury --keyring-backend $KEYRING --chain-id $CHAINID
#fury gentx $KEY2 1000000000000000000000ufury --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
fury collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
fury validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
# fury start --pruning=nothing --trace --log_level trace --minimum-gas-prices=1.000ufury --json-rpc.api eth,txpool,personal,net,debug,web3 --rpc.laddr "tcp://0.0.0.0:26657" --api.enable true --api.enabled-unsafe-cors true

