;; Capped Token Contract
;; A robust SIP-010 compliant token with supply cap and advanced features

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_UNAUTHORIZED (err u103))
(define-constant ERR_CAP_EXCEEDED (err u104))
(define-constant ERR_PAUSED (err u107))

;; Token configuration
(define-fungible-token capped-token u1000000000)
(define-constant TOKEN_NAME "Capped Token")
(define-constant TOKEN_SYMBOL "CAP")
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_CAP u1000000000)

;; Data variables
(define-data-var contract-owner principal CONTRACT_OWNER)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var paused bool false)
(define-data-var total-supply uint u0)

;; Data maps
(define-map minters principal bool)
(define-map blacklisted principal bool)

;; Private functions
(define-private (is-owner)
  (is-eq tx-sender (var-get contract-owner)))

(define-private (is-minter)
  (default-to false (map-get? minters tx-sender)))

(define-private (is-user-blacklisted (user principal))
  (default-to false (map-get? blacklisted user)))

;; SIP-010 trait implementation
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (not (is-user-blacklisted sender)) ERR_UNAUTHORIZED)
    (asserts! (not (is-user-blacklisted recipient)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (try! (ft-transfer? capped-token amount sender recipient))
    (print {action: "transfer", sender: sender, recipient: recipient, amount: amount})
    (ok true)))

(define-read-only (get-name)
  (ok TOKEN_NAME))

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL))

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS))

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance capped-token user)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;; Enhanced functionality
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (or (is-owner) (is-minter)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-user-blacklisted recipient)) ERR_UNAUTHORIZED)
    (let ((new-supply (+ (var-get total-supply) amount)))
      (asserts! (<= new-supply TOKEN_CAP) ERR_CAP_EXCEEDED)
      (try! (ft-mint? capped-token amount recipient))
      (var-set total-supply new-supply)
      (print {action: "mint", recipient: recipient, amount: amount, new-supply: new-supply})
      (ok true))))

(define-public (burn (amount uint))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-user-blacklisted tx-sender)) ERR_UNAUTHORIZED)
    (try! (ft-burn? capped-token amount tx-sender))
    (var-set total-supply (- (var-get total-supply) amount))
    (print {action: "burn", user: tx-sender, amount: amount})
    (ok true)))

;; Simple dual transfer function
(define-public (transfer-two (recipient1 principal) (amount1 uint) (recipient2 principal) (amount2 uint))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (not (is-user-blacklisted tx-sender)) ERR_UNAUTHORIZED)
    (asserts! (not (is-user-blacklisted recipient1)) ERR_UNAUTHORIZED)
    (asserts! (not (is-user-blacklisted recipient2)) ERR_UNAUTHORIZED)
    (asserts! (> amount1 u0) ERR_INVALID_AMOUNT)
    (asserts! (> amount2 u0) ERR_INVALID_AMOUNT)
    (try! (ft-transfer? capped-token amount1 tx-sender recipient1))
    (try! (ft-transfer? capped-token amount2 tx-sender recipient2))
    (print {action: "dual-transfer", caller: tx-sender})
    (ok true)))

;; Admin functions
(define-public (set-token-uri (new-uri (string-utf8 256)))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (var-set token-uri (some new-uri))
    (ok true)))

(define-public (add-minter (minter principal))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (map-set minters minter true)
    (print {action: "minter-added", minter: minter})
    (ok true)))

(define-public (remove-minter (minter principal))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (map-delete minters minter)
    (print {action: "minter-removed", minter: minter})
    (ok true)))

(define-public (blacklist-user (user principal))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (map-set blacklisted user true)
    (print {action: "user-blacklisted", user: user})
    (ok true)))

(define-public (unblacklist-user (user principal))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (map-delete blacklisted user)
    (print {action: "user-unblacklisted", user: user})
    (ok true)))

(define-public (pause-contract)
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (var-set paused true)
    (print {action: "contract-paused"})
    (ok true)))

(define-public (unpause-contract)
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (var-set paused false)
    (print {action: "contract-unpaused"})
    (ok true)))

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-owner) ERR_OWNER_ONLY)
    (var-set contract-owner new-owner)
    (print {action: "ownership-transferred", new-owner: new-owner})
    (ok true)))

;; Read-only functions
(define-read-only (get-owner)
  (var-get contract-owner))

(define-read-only (is-paused)
  (var-get paused))

(define-read-only (get-cap)
  TOKEN_CAP)

(define-read-only (get-remaining-cap)
  (- TOKEN_CAP (var-get total-supply)))

(define-read-only (check-minter (user principal))
  (default-to false (map-get? minters user)))

(define-read-only (check-blacklisted (user principal))
  (is-user-blacklisted user))

;; Emergency functions
(define-public (emergency-pause)
  (begin
    (asserts! (or (is-owner) (is-minter)) ERR_UNAUTHORIZED)
    (var-set paused true)
    (print {action: "emergency-pause", caller: tx-sender})
    (ok true)))

;; Bulk mint function for initial distribution
(define-public (bulk-mint (amount1 uint) (recipient1 principal) (amount2 uint) (recipient2 principal))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (or (is-owner) (is-minter)) ERR_UNAUTHORIZED)
    (asserts! (> amount1 u0) ERR_INVALID_AMOUNT)
    (asserts! (> amount2 u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-user-blacklisted recipient1)) ERR_UNAUTHORIZED)
    (asserts! (not (is-user-blacklisted recipient2)) ERR_UNAUTHORIZED)
    (let ((total-mint (+ amount1 amount2))
          (new-supply (+ (var-get total-supply) total-mint)))
      (asserts! (<= new-supply TOKEN_CAP) ERR_CAP_EXCEEDED)
      (try! (ft-mint? capped-token amount1 recipient1))
      (try! (ft-mint? capped-token amount2 recipient2))
      (var-set total-supply new-supply)
      (print {action: "bulk-mint", total: total-mint})
      (ok true))))

;; Token info function
(define-read-only (get-token-info)
  {
    name: TOKEN_NAME,
    symbol: TOKEN_SYMBOL,
    decimals: TOKEN_DECIMALS,
    total-supply: (var-get total-supply),
    max-supply: TOKEN_CAP,
    owner: (var-get contract-owner),
    paused: (var-get paused)
  })

;; Initialize contract
(map-set minters CONTRACT_OWNER true)