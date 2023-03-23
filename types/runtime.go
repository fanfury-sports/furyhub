package types

// MUST be loaded before running
import (
	"math"
	"os"
	"path/filepath"

	"github.com/tendermint/tendermint/crypto"

	sdk "github.com/cosmos/cosmos-sdk/types"

	"github.com/furynet/furyhub/address"
	tokentypes "github.com/irisnet/irismod/modules/token/types"
	tokenv1 "github.com/irisnet/irismod/modules/token/types/v1"
)

const (
	AppName = "FuryApp"
)

var (
	NativeToken     tokenv1.Token
	EvmToken        tokenv1.Token
	DefaultNodeHome string
)

func init() {
	// set bech32 prefix
	address.ConfigureBech32Prefix()

	// set coin denom regexs
	sdk.SetCoinDenomRegex(func() string {
		return `[a-zA-Z][a-zA-Z0-9/-]{2,127}`
	})

	NativeToken = tokenv1.Token{
		Symbol:        "fury",
		Name:          "Furyhub staking token",
		Scale:         6,
		MinUnit:       "ufury",
		InitialSupply: 2000000000,
		MaxSupply:     10000000000,
		Mintable:      true,
		Owner:         sdk.AccAddress(crypto.AddressHash([]byte(tokentypes.ModuleName))).String(),
	}

	// TODO
	EvmToken = tokenv1.Token{
		Symbol:        "eth",
		Name:          "Furyhub evm token",
		Scale:         18,
		MinUnit:       "wei",
		InitialSupply: 0,
		MaxSupply:     math.MaxUint64,
		Mintable:      true,
		Owner:         sdk.AccAddress(crypto.AddressHash([]byte(tokentypes.ModuleName))).String(),
	}

	userHomeDir, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}

	DefaultNodeHome = filepath.Join(userHomeDir, ".fury")
	owner, err := sdk.AccAddressFromBech32(NativeToken.Owner)
	if err != nil {
		panic(err)
	}

	// replace the default token
	tokenv1.SetNativeToken(
		NativeToken.Symbol,
		NativeToken.Name,
		NativeToken.MinUnit,
		NativeToken.Scale,
		NativeToken.InitialSupply,
		NativeToken.MaxSupply,
		NativeToken.Mintable,
		owner,
	)
}
