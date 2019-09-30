local _={}
_[7]={32,32,32,32}
_[6]={0,32,32,32}
_[5]={32,0,32,32}
_[4]={0,0,32,32}
_[3]={stframe=0,enframe=3,name="idle"}
_[2]={_[4],_[5],_[6],_[7]}
_[1]={_[3]}
return {tilew=32,image="rabbit-boss.png",tileh=32,animations=_[1],name="forest",quads=_[2]}