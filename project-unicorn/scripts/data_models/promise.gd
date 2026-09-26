class_name Promise
extends Resource

# A commitment the founder (or a CS rep) made to a B2B customer: ship a specific
# product feature by a deadline. Lives in PromiseRegistry.
#
# Created through PromiseRegistry.create — by the `promise_create` card effect and by a
# pitch promise at the signature (SalesFinalizer). Resolved when the promised feature ships
# (kept), the deadline passes with it unshipped (broken), or it ships late (partial). Plain
# data container — lifecycle logic lives in PromiseRegistry + B2BSalesSystem.

@export var id: String = ""               # "promise_<customer>_<feature>_<day>"
@export var customer_id: String = ""      # the account the word was given to
@export var feature_id: String = ""       # the ProductCatalog feature that must ship
@export var deadline_day: int = 0         # GameState.day by which it must ship
@export var created_on_day: int = 0
@export var status: String = "open"       # "open" | "kept" | "broken" | "partial"
