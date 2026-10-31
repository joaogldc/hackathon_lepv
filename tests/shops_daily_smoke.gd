extends Node
const SHOP := preload("res://scripts/core/shop_catalog.gd")
func _ready() -> void:
 var world:=preload("res://scenes/world/lobby.tscn").instantiate()
 add_child(world)
 Progress.storage_path="user://shops_server_smoke.json"
 Progress.profiles={}
 assert(Network.host("ShopTest",false,19108)==OK)
 var p: Dictionary=Progress.profiles[Progress.player_keys[1]]
 p.coins=5000
 Progress._publish(1)
 Network.interact("buy","camisa_azul")
 assert(p.coins==5000 and not p.owned.has("camisa_azul"),"Purchases outside a counter must fail")
 Network.players[1].zone="loja_cosmeticos"
 Network.players[1].position=Vector2(576,480)
 Network.roster_changed.emit()
 world._interact_nearby()
 assert(world.commerce_ui.page=="cosmetics")
 Network.interact("outfit","camisa_azul")
 assert(p.outfit=="none","Unowned clothes cannot be equipped")
 var count:=0
 for product in SHOP.ITEMS:
  if not product.has("garment"): continue
  count+=1
  var before: int=p.coins
  Network.interact("buy",product.id)
  assert(p.coins==before-product.price and p.owned.has(product.id) and p.outfit==product.id)
  Network.interact("buy",product.id)
  assert(p.coins==before-product.price,"A repeated purchase must not charge twice")
 assert(count==10)
 var before: int=p.coins
 p.coins=0
 Network.interact("buy","cartola")
 assert(not p.owned.has("cartola") and p.coins==0,"Insufficient funds must not grant ownership")
 p.coins=before
 Network.players[1].zone="provador"
 Network.players[1].position=Vector2(576,580)
 Network.interact("outfit","terno_vinho")
 assert(Network.players[1].outfit=="terno_vinho")
 Network.interact("outfit","none")
 assert(Network.players[1].outfit=="none")
 Network.players[1].zone="loja_pets"
 Network.players[1].position=Vector2(576,480)
 Network.interact("pet","parrot")
 assert(p.pet=="fish","Unowned pet must not be equipped")
 Network.interact("buy","parrot")
 assert(p.pet=="parrot" and p.coins==before-140)
 Network.interact("pet","fish")
 assert(p.pet=="fish")
 Network.interact("pet","parrot")
 assert(p.pet=="parrot")
 # Acessórios de pet: compra, equipar, restrição por espécie e local.
 var coins_acc: int=p.coins
 Network.interact("buy","pet_tapa_olho")
 assert(p.pet_acc=="pet_tapa_olho" and p.coins==coins_acc-80 and p.owned.has("pet_tapa_olho"))
 Network.interact("buy","pet_tapa_olho")
 assert(p.coins==coins_acc-80,"Acessório já comprado não cobra de novo")
 Network.interact("pet_acc","pet_coroa")
 assert(p.pet_acc=="pet_tapa_olho","Acessório não comprado não pode ser equipado")
 Network.interact("pet_acc","none")
 assert(p.pet_acc=="none")
 Network.interact("pet","fish")
 Network.interact("pet_acc","pet_tapa_olho")
 assert(p.pet_acc=="none","Tapa-olho só existe para a arara")
 Network.interact("buy","pet_tapa_olho")
 Network.interact("buy","pet_coroa")
 assert(p.pet_acc=="pet_coroa" and p.owned.has("pet_coroa"))
 Network.players[1].zone="lobby"
 Network.interact("pet_acc","none")
 assert(p.pet_acc=="pet_coroa","Troca de acessório fora da loja deve ser rejeitada")
 Network.players[1].zone="loja_pets"
 Network.interact("pet","parrot")
 assert(p.pet=="parrot")
 var saved=JSON.parse_string(FileAccess.get_file_as_string(Progress.storage_path))
 assert(saved[Progress.player_keys[1]].owned.has("terno_vinho"))
 assert(saved[Progress.player_keys[1]].pet=="parrot")
 var result:={"ids":[1,999],"names":["ShopTest","Rival"],"winner":0,"feedback":"Vitória!"}
 Duel._reward_result(result,true)
 Duel._reward_result(result,true)
 assert(p.badges==["first_daily_win"] and p.wins==1)
 assert(result.xp_rewards[0]>0)
 var xp: int=p.xp
 world._show_result(result)
 world.recompensa_moedas._continuar()
 world.recompensa_moedas._continuar()
 assert(world.recompensa_xp.visible)
 world.recompensa_xp._continuar()
 assert(world.recompensa_xp.xp_exibido==result.xp_rewards[0] and p.xp==xp,"Animation cannot credit XP twice")
 Progress._roll_day(p,Progress.day_number()+1)
 assert(p.badges==["first_daily_win"],"Badge must survive daily rollover")
 print("SHOPS DAILY PASS: ten clothing purchases, counter validation, ownership, insufficient funds, duplicate purchase, pet exchange, persistence, one badge and real XP")
 get_tree().quit()
