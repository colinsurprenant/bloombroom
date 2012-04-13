# based on https://github.com/andyjeffries/digestfnv

module Bloombroom 
  class FNVA

    OFFSET32   = 2166136261
    OFFSET64   = 14695981039346656037
    OFFSET128  = 144066263297769815596495629667062367629
    OFFSET256  = 100029257958052580907070968620625704837092796014241193945225284501741471925557
    OFFSET512  = 9659303129496669498009435400716310466090418745672637896108374329434462657994582932197716438449813051892206539805784495328239340083876191928701583869517785
    OFFSET1024 = 14197795064947621068722070641403218320880622795441933960878474914617582723252296732303717722150864096521202355549365628174669108571814760471015076148029755969804077320157692458563003215304957150157403644460363550505412711285966361610267868082893823963790439336411086884584107735010676915

    PRIME32   = 16777619
    PRIME64   = 1099511628211
    PRIME128  = 309485009821345068724781371
    PRIME256  = 374144419156711147060143317175368453031918731002211
    PRIME512  = 35835915874844867368919076489095108449946327955754392558399825615420669938882575126094039892345713852759
    PRIME1024 = 5016456510113118655434598811035278955030765345404790744303017523831112055108147451509157692220295382716162651878526895249385292291816524375083746691371804094271873160484737966720260389217684476157468082573

    MASK32   = (2 ** 32) - 1
    MASK64   = (2 ** 64) - 1
    MASK128  = (2 ** 128) - 1
    MASK256  = (2 ** 256) - 1
    MASK512  = (2 ** 512) - 1
    MASK1024 = (2 ** 1024) - 1

    def self.fnv1_32(input)
      hash = OFFSET32
      input.each_byte { |b| hash = (hash * PRIME32) ^ b }
      hash & MASK32
    end
    
    def self.fnv1_64(input)
      hash = OFFSET64
      input.each_byte { |b| hash = (hash * PRIME64) ^ b }
      hash & MASK64
    end

    def self.fnv1_128(input)
      hash = OFFSET128
      input.each_byte { |b| hash = (hash * PRIME128) ^ b }
      hash & MASK128
    end

    def self.fnv1_256(input)
      hash = OFFSET256
      input.each_byte { |b| hash = (hash * PRIME256) ^ b }
      hash & MASK256
    end

    def self.fnv1_512(input)
      hash = OFFSET512
      input.each_byte { |b| hash = (hash * PRIME512) ^ b }
      hash & MASK512
    end

    def self.fnv1_1024(input)
      hash = OFFSET1024
      input.each_byte { |b| hash = (hash * PRIME1024) ^ b }
      hash & MASK1024
    end

    def self.fnv1a_32(input)
      hash = OFFSET32
      input.each_byte { |b| hash = (hash ^ b) * PRIME32 }
      hash & MASK32
    end
    
    def self.fnv1a_64(input)
      hash = OFFSET64
      input.each_byte { |b| hash = (hash ^ b) * PRIME64 }
      hash & MASK64
    end

    def self.fnv1a_128(input)
      hash = OFFSET128
      input.each_byte { |b| hash = (hash ^ b) * PRIME128 }
      hash & MASK128
    end

    def self.fnv1a_256(input)
      hash = OFFSET256
      input.each_byte { |b| hash = (hash ^ b) * PRIME256 }
      hash & MASK256
    end

    def self.fnv1a_512(input)
      hash = OFFSET512
      input.each_byte { |b| hash = (hash ^ b) * PRIME512 }
      hash & MASK512
    end

    def self.fnv1a_1024(input)
      hash = OFFSET1024
      input.each_byte { |b| hash = (hash ^ b) * PRIME1024 }
      hash & MASK1024
    end

  end
end