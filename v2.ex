defmodule Febrd.CoinBase do
  @coinbase_base_url "https://api.coinbase.com/v2"
  @coinmarketcap_base_url "https://pro-api.coinmarketcap.com/v1"
  @coinbase_api_key Application.get_env(:febrd, :coinbase_api_key)
  @coinbase_api_secret Application.get_env(:febrd, :coinbase_api_secret)
  @coinmarketcap_api_key Application.get_env(:febrd, :coinmarketcap_api_key)

  # Common function for making GET requests to Coinbase
  def get_coinbase(endpoint, params \\ %{}, headers \\ %{}) do
    url = @coinbase_base_url <> endpoint
    headers = Map.merge(headers, coinbase_headers(endpoint, params))

    {:ok, response} = HTTPoison.get(url, params, headers)
    
    response
  end

  # Common function for making POST requests to Coinbase
  defp post_coinbase(endpoint, body, headers \\ %{}) do
    url = @coinbase_base_url <> endpoint
    headers = Map.merge(headers, coinbase_headers(endpoint, body))

    {:ok, response} = HTTPoison.post(url, body, headers)
    response
  end

  # Function to get the required headers for Coinbase requests
  defp coinbase_headers(endpoint, body) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    signature = coinbase_signature(endpoint, body, timestamp)

    %{
      "CB-ACCESS-KEY" => @coinbase_api_key,
      "CB-ACCESS-SIGN" => signature,
      "CB-ACCESS-TIMESTAMP" => "#{timestamp}",
      "CB-VERSION" => "2018-01-23"
    }
  end

  # Function to generate Coinbase signature
  defp coinbase_signature(endpoint, body, timestamp) do
    prehash = "#{timestamp}GET#{endpoint}#{body}"
    key = Base.decode64!(@coinbase_api_secret)
    hmac = :crypto.hmac(:sha256, key, prehash, [:binary])
    Base.encode16(hmac)
  end

  # Functions for Coinbase

  # Function to get Coinbase orders
  def get_coinbase_orders(account_id, params \\ %{}) do
    endpoint = "/accounts/#{account_id}/orders"
    get_coinbase(endpoint, params)

   end

  # Function to create a new Coinbase order
  def create_coinbase_order(account_id, params) do
    endpoint = "/accounts/#{account_id}/orders"
    post_coinbase(endpoint, params)

    end

  # Function to cancel a Coinbase order by order ID
  def cancel_coinbase_order(account_id, order_id) do
    endpoint = "/accounts/#{account_id}/orders/#{order_id}/cancel"
    post_coinbase(endpoint, %{})

    end

  # Function to get order fills on Coinbase by order ID
  def get_coinbase_fills(account_id, order_id, params \\ %{}) do
    endpoint = "/accounts/#{account_id}/orders/#{order_id}/fills"
    get_coinbase(endpoint, params)

    end

  # Function to get Coinbase accounts
  def get_coinbase_accounts(params \\ %{}) do
    endpoint = "/accounts"
    get_coinbase(endpoint, params)

    end

  # Function to get Coinbase account balance by account ID
  def get_coinbase_account_balance(account_id) do
    endpoint = "/accounts/#{account_id}/balance"
    get_coinbase(endpoint)

    end

  # Function to get Coinbase account transfers by account ID
  def get_coinbase_account_transfers(account_id, params \\ %{}) do
    endpoint = "/accounts/#{account_id}/transfers"
    get_coinbase(endpoint, params)

  end

  # Function to get Coinbase account holds by account ID
  def get_coinbase_account_holds(account_id, params \\ %{}) do
    endpoint = "/accounts/#{account_id}/holds"
    get_coinbase(endpoint, params)

    end
end
