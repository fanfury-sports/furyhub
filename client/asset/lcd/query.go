package lcd

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/irisnet/irishub/client/context"
	"github.com/irisnet/irishub/codec"
)

func registerQueryRoutes(cliCtx context.CLIContext, r *mux.Router, cdc *codec.Codec) {
	// Get the gateway from a moniker
	r.HandleFunc(
		"/asset/gateways/{Moniker}/gateway",
		monikerGatewayHandlerFn(cliCtx, cdc),
	).Methods("GET")

	// Get all gateways from an owner
	r.HandleFunc(
		"/asset/gateways/{Owner}/gateways",
		ownerGatewaysHandlerFn(cliCtx, cdc),
	).Methods("GET")
}

// monikerGatewayHandlerFn is the HTTP request handler to query a gateway of the given moniker
func monikerGatewayHandlerFn(cliCtx context.CLIContext, cdc *codec.Codec) http.HandlerFunc {
	return queryGateway(cliCtx, cdc, "custom/asset/gateway")
}

// ownerGatewaysHandlerFn is the HTTP request handler to query all the gateways of the specifed owner
func ownerGatewaysHandlerFn(cliCtx context.CLIContext, cdc *codec.Codec) http.HandlerFunc {
	return queryGateways(cliCtx, cdc, "custom/asset/gateways")
}
