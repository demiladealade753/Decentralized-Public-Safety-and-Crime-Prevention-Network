;; Evidence Chain of Custody Contract
;; Maintains secure records of physical evidence in criminal cases

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-INVALID-INPUT (err u301))
(define-constant ERR-NOT-FOUND (err u302))
(define-constant ERR-ALREADY-EXISTS (err u303))
(define-constant ERR-INVALID-TRANSFER (err u304))

;; Data Variables
(define-data-var next-evidence-id uint u1)
(define-data-var next-transfer-id uint u1)

;; Data Maps
(define-map authorized-personnel principal {
    name: (string-ascii 100),
    badge-number: (string-ascii 50),
    department: (string-ascii 100),
    role: (string-ascii 50),
    active: bool
})

(define-map evidence-items uint {
    case-number: (string-ascii 50),
    item-type: (string-ascii 100),
    description: (string-ascii 500),
    collection-date: uint,
    collection-location: (string-ascii 200),
    collected-by: principal,
    current-custodian: principal,
    status: (string-ascii 20),
    hash-value: (string-ascii 64),
    storage-location: (string-ascii 100)
})

(define-map custody-transfers uint {
    evidence-id: uint,
    from-custodian: principal,
    to-custodian: principal,
    transfer-date: uint,
    reason: (string-ascii 200),
    transfer-location: (string-ascii 100),
    authorized-by: principal,
    notes: (string-ascii 500),
    status: (string-ascii 20)
})

(define-map evidence-access-log uint {
    evidence-id: uint,
    accessed-by: principal,
    access-date: uint,
    access-type: (string-ascii 50),
    purpose: (string-ascii 200),
    duration: uint,
    authorized-by: principal
})

(define-map case-evidence (string-ascii 50) (list 50 uint))

;; Public Functions

;; Register authorized personnel
(define-public (register-personnel (personnel principal) (name (string-ascii 100)) (badge-number (string-ascii 50)) (department (string-ascii 100)) (role (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (> (len name) u0) ERR-INVALID-INPUT)
        (asserts! (> (len badge-number) u0) ERR-INVALID-INPUT)
        (asserts! (> (len department) u0) ERR-INVALID-INPUT)
        (asserts! (> (len role) u0) ERR-INVALID-INPUT)
        (map-set authorized-personnel personnel {
            name: name,
            badge-number: badge-number,
            department: department,
            role: role,
            active: true
        })
        (ok true)
    )
)

;; Log evidence item
(define-public (log-evidence (case-number (string-ascii 50)) (item-type (string-ascii 100)) (description (string-ascii 500)) (collection-location (string-ascii 200)) (hash-value (string-ascii 64)) (storage-location (string-ascii 100)))
    (let ((evidence-id (var-get next-evidence-id)))
        (asserts! (is-some (map-get? authorized-personnel tx-sender)) ERR-NOT-AUTHORIZED)
        (asserts! (> (len case-number) u0) ERR-INVALID-INPUT)
        (asserts! (> (len item-type) u0) ERR-INVALID-INPUT)
        (asserts! (> (len description) u0) ERR-INVALID-INPUT)
        (asserts! (> (len collection-location) u0) ERR-INVALID-INPUT)
        (asserts! (> (len hash-value) u0) ERR-INVALID-INPUT)
        (map-set evidence-items evidence-id {
            case-number: case-number,
            item-type: item-type,
            description: description,
            collection-date: block-height,
            collection-location: collection-location,
            collected-by: tx-sender,
            current-custodian: tx-sender,
            status: "collected",
            hash-value: hash-value,
            storage-location: storage-location
        })
        (var-set next-evidence-id (+ evidence-id u1))
        (try! (add-evidence-to-case case-number evidence-id))
        (ok evidence-id)
    )
)

;; Transfer evidence custody
(define-public (transfer-custody (evidence-id uint) (to-custodian principal) (reason (string-ascii 200)) (transfer-location (string-ascii 100)) (notes (string-ascii 500)))
    (let ((evidence (unwrap! (map-get? evidence-items evidence-id) ERR-NOT-FOUND))
          (transfer-id (var-get next-transfer-id)))
        (asserts! (is-some (map-get? authorized-personnel tx-sender)) ERR-NOT-AUTHORIZED)
        (asserts! (is-some (map-get? authorized-personnel to-custodian)) ERR-INVALID-TRANSFER)
        (asserts! (is-eq tx-sender (get current-custodian evidence)) ERR-NOT-AUTHORIZED)
        (asserts! (> (len reason) u0) ERR-INVALID-INPUT)
        (asserts! (> (len transfer-location) u0) ERR-INVALID-INPUT)

        ;; Record the transfer
        (map-set custody-transfers transfer-id {
            evidence-id: evidence-id,
            from-custodian: tx-sender,
            to-custodian: to-custodian,
            transfer-date: block-height,
            reason: reason,
            transfer-location: transfer-location,
            authorized-by: tx-sender,
            notes: notes,
            status: "completed"
        })

        ;; Update evidence custodian
        (map-set evidence-items evidence-id (merge evidence {
            current-custodian: to-custodian,
            status: "transferred"
        }))

        (var-set next-transfer-id (+ transfer-id u1))
        (ok transfer-id)
    )
)

;; Log evidence access
(define-public (log-access (evidence-id uint) (access-type (string-ascii 50)) (purpose (string-ascii 200)) (duration uint))
    (let ((evidence (unwrap! (map-get? evidence-items evidence-id) ERR-NOT-FOUND)))
        (asserts! (is-some (map-get? authorized-personnel tx-sender)) ERR-NOT-AUTHORIZED)
        (asserts! (> (len access-type) u0) ERR-INVALID-INPUT)
        (asserts! (> (len purpose) u0) ERR-INVALID-INPUT)
        (asserts! (> duration u0) ERR-INVALID-INPUT)

        (map-set evidence-access-log (var-get next-transfer-id) {
            evidence-id: evidence-id,
            accessed-by: tx-sender,
            access-date: block-height,
            access-type: access-type,
            purpose: purpose,
            duration: duration,
            authorized-by: (get current-custodian evidence)
        })
        (ok true)
    )
)

;; Update evidence status
(define-public (update-evidence-status (evidence-id uint) (status (string-ascii 20)))
    (let ((evidence (unwrap! (map-get? evidence-items evidence-id) ERR-NOT-FOUND)))
        (asserts! (is-some (map-get? authorized-personnel tx-sender)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq tx-sender (get current-custodian evidence)) ERR-NOT-AUTHORIZED)
        (map-set evidence-items evidence-id (merge evidence { status: status }))
        (ok true)
    )
)

;; Deactivate personnel
(define-public (deactivate-personnel (personnel principal))
    (let ((person (unwrap! (map-get? authorized-personnel personnel) ERR-NOT-FOUND)))
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (map-set authorized-personnel personnel (merge person { active: false }))
        (ok true)
    )
)

;; Private Functions

;; Add evidence to case list
(define-private (add-evidence-to-case (case-number (string-ascii 50)) (evidence-id uint))
    (let ((current-list (default-to (list) (map-get? case-evidence case-number))))
        (map-set case-evidence case-number (unwrap! (as-max-len? (append current-list evidence-id) u50) ERR-INVALID-INPUT))
        (ok true)
    )
)

;; Read-only Functions

;; Get evidence item
(define-read-only (get-evidence-item (evidence-id uint))
    (map-get? evidence-items evidence-id)
)

;; Get custody transfer
(define-read-only (get-custody-transfer (transfer-id uint))
    (map-get? custody-transfers transfer-id)
)

;; Get personnel info
(define-read-only (get-personnel (personnel principal))
    (map-get? authorized-personnel personnel)
)

;; Get case evidence list
(define-read-only (get-case-evidence (case-number (string-ascii 50)))
    (map-get? case-evidence case-number)
)

;; Get evidence access log
(define-read-only (get-access-log (log-id uint))
    (map-get? evidence-access-log log-id)
)

;; Verify evidence integrity
(define-read-only (verify-evidence-integrity (evidence-id uint) (provided-hash (string-ascii 64)))
    (match (map-get? evidence-items evidence-id)
        evidence (is-eq (get hash-value evidence) provided-hash)
        false
    )
)

;; Get custody chain for evidence
(define-read-only (get-custody-chain (evidence-id uint))
    ;; In a full implementation, this would return the complete chain
    ;; For now, returns the current custodian
    (match (map-get? evidence-items evidence-id)
        evidence (some (get current-custodian evidence))
        none
    )
)
