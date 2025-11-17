@abstract
class_name EffectComponent extends Resource

func apply(_actor: Monster, _target: Monster, _context: Dictionary) -> bool:
	return true
	
func can_apply(_actor: Monster, _target: Monster, _context: Dictionary) -> bool:
	return true
