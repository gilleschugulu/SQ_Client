Array.prototype.unique = function () {
    var r = [];
    o:for(var i = 0, n = this.length; i < n; i++)
    {
        for(var x = 0, y = r.length; x < y; x++)
      {
        if(r[x]===this[i])
        {
          continue o;
        }
      }
      r[r.length] = this[i];
    }
    return r;
};
