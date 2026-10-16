local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

-- "a, b,c" のような変数リストから "cin >> a >> b >> c;" を生成する
local function cin_line(args)
    local vars = {}
    for v in args[1][1]:gmatch("[^,%s]+") do
        table.insert(vars, v)
    end
    if #vars == 0 then
        return "cin >> ;"
    end
    return "cin >> " .. table.concat(vars, " >> ") .. ";"
end

ls.add_snippets("cpp", {
    s("ll", {
        t("long long"),
    }),
    s("rep", {
        t("for (int "), i(1, "i"), t(" = 0; "), rep(1), t(" < "), i(2, "n"), t("; ++"), rep(1), t(")"),
        t({ "", "{" }),
        t({ "", "  " }), i(3),
        t({ "", "}" }),
    }),
    s("rep1", {
        t("for (int "), i(1, "i"), t(" = 1; "), rep(1), t(" <= "), i(2, "n"), t("; ++"), rep(1), t(")"),
        t({ "", "{" }),
        t({ "", "  " }), i(3),
        t({ "", "}" }),
    }),
    s("rrep", {
        t("for (int "), i(1, "i"), t(" = "), i(2, "n"), t(" - 1; "), rep(1), t(" >= 0; --"), rep(1), t(")"),
        t({ "", "{" }),
        t({ "", "  " }), i(3),
        t({ "", "}" }),
    }),
    s("repa", {
        t("for (auto& "), i(1, "e"), t(" : "), i(2, "v"), t(")"),
        t({ "", "{" }),
        t({ "", "  " }), i(3),
        t({ "", "}" }),
    }),
    -- rep + if の組み合わせ。配列を線形探索して条件が成立したら何かする形（例: ans = 1;）
    -- A問題早解き専用命名（aaプレフィックス）: aaif
    s("aaif", {
        t("for (int "), i(1, "i"), t(" = 0; "), rep(1), t(" < "), i(2, "n"), t("; ++"), rep(1), t(")"),
        t({ "", "{" }),
        t({ "", "  if (" }), i(3, "a[i] == x"), t(") "), i(4, "ans = 1"), t(";"),
        t({ "", "}" }),
    }),
    s("repm", {
        t("for (auto& ["), i(1, "k"), t(", "), i(2, "v"), t("] : "), i(3, "mp"), t(")"),
        t({ "", "{" }),
        t({ "", "  " }), i(4),
        t({ "", "}" }),
    }),
    -- bit全探索。n個の要素それぞれの「選ぶ/選ばない」を2^n通り試す（n≦20が目安）
    -- 外側のbitが選び方、内側でi番目が選ばれているかを判定する
    s("bitall", {
        t("for (int bit = 0; bit < (1 << "), i(1, "n"), t("); ++bit)"),
        t({ "", "{" }),
        t({ "", "  for (int " }), i(2, "i"), t(" = 0; "), rep(2), t(" < "), rep(1), t("; ++"), rep(2), t(")"),
        t({ "", "  {" }),
        t({ "", "    if (bit >> " }), rep(2), t(" & 1)"),
        t({ "", "    {" }),
        t({ "", "      " }), i(3),
        t({ "", "    }" }),
        t({ "", "  }" }),
        t({ "", "}" }),
    }),
    s("dbg", {
        t("dbg("), i(1), t(");"),
    }),
    s("cini", {
        t("int "), i(1, "a, b"), t("; "),
        f(cin_line, { 1 }),
    }),
    -- cini のA問題早解き専用エイリアス（aaプレフィックス）。内容はciniと同一
    s("aai", {
        t("int "), i(1, "a, b"), t("; "),
        f(cin_line, { 1 }),
    }),
    s("cinl", {
        t("long long "), i(1, "a, b"), t("; "),
        f(cin_line, { 1 }),
    }),
    s("cins", {
        t("string "), i(1, "s"), t("; "),
        f(cin_line, { 1 }),
    }),
    -- n を読んで長さ n の配列を一括入力（vector版・推奨。大きいnでも安全）
    s("cinv", {
        t("int "), i(1, "n"), t("; cin >> "), rep(1), t(";"),
        t({ "", "vector<" }), i(2, "int"), t("> "), i(3, "a"), t("("), rep(1), t(");"),
        t({ "", "for (int " }), i(4, "i"), t(" = 0; "), rep(4), t(" < "), rep(1), t("; ++"), rep(4), t(") cin >> "), rep(3), t("["), rep(4), t("];"),
    }),
    -- 同上の生配列/VLA版（GCC拡張。大きいnはスタック溢れ注意）
    s("cina", {
        t("int "), i(1, "n"), t("; cin >> "), rep(1), t(";"),
        t({ "", "" }), i(2, "int"), t(" "), i(3, "a"), t("["), rep(1), t("];"),
        t({ "", "for (int " }), i(4, "i"), t(" = 0; "), rep(4), t(" < "), rep(1), t("; ++"), rep(4), t(") cin >> "), rep(3), t("["), rep(4), t("];"),
    }),
    -- cinaの高速版。変数名・型をn/int/a/iに固定してタブストップを無くし、即展開して次のコード位置へ
    -- A問題早解き専用命名（aaプレフィックス）: aan
    s("aan", {
        t({
            "int n; cin >> n;",
            "int a[n];",
            "for (int i = 0; i < n; ++i) cin >> a[i];",
        }),
    }),
    s("cl", {
        t("cout << "), i(1, "ans"), t(' << "\\n";'),
    }),
    -- Yes/No 出力。条件部分にカーソルが来る
    s("yn", {
        t('cout << ('), i(1, "cond"), t(' ? "Yes" : "No") << endl;'),
    }),
    -- 整数べき（繰り返し二乗法）。pow の浮動小数点誤差を避ける
    s("power", {
        t({
            "long long power(long long base, long long exp)",
            "{",
            "  long long result = 1;",
            "  while (exp > 0)",
            "  {",
            "    if (exp & 1) result *= base;",
            "    base *= base;",
            "    exp >>= 1;",
            "  }",
            "  return result;",
            "}",
        }),
    }),
    -- 素朴な整数べき（インライン。指数が小さいと分かっている時用）。int溢れ回避でll
    s("pw", {
        t("long long "), i(1, "ans"), t(" = 1;"),
        t({ "", "for (int " }), i(2, "i"), t(" = 0; "), rep(2), t(" < "), i(3, "b"), t("; ++"), rep(2), t(") "), rep(1), t(" *= "), i(4, "a"), t(";"),
    }),
    -- 引き算後などで負になり得る変数をその場で正規化。
    -- 非負の値に対しても結果は変わらないため、負になり得るか毎回考えず常用してよい
    s("md", {
        i(1, "ans"), t(" = ("), rep(1), t(" % "), i(2, "mod"), t(" + "), rep(2), t(") % "), rep(2), t(";"),
    }),
    -- flagの中身(cond)をtrue/falseで判定し、そのままYes/No出力する単純版
    s("flagflag", {
        t("bool flag = ("), i(1, "cond"), t(");"),
        t({ "", 'cout << (flag ? "Yes" : "No") << "\\n";' }),
    }),
    -- flagflag3のif-else版
    s("flagflag2", (function()
        local nodes = {}
        local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        table.insert(nodes, t("bool flagA;"))
        table.insert(nodes, t({ "", "if (" }))
        table.insert(nodes, i(1))
        table.insert(nodes, t(")"))
        table.insert(nodes, t({ "", "{" }))
        table.insert(nodes, t({ "", "  flagA = true;" }))
        table.insert(nodes, t({ "", "}" }))
        table.insert(nodes, t({ "", "else" }))
        table.insert(nodes, t({ "", "{" }))
        table.insert(nodes, t({ "", "  flagA = false;" }))
        table.insert(nodes, t({ "", "}" }))
        for idx = 2, #letters do
            local letter = letters:sub(idx, idx)
            local prev = letters:sub(idx - 1, idx - 1)
            table.insert(nodes, t({ "", "bool flag" .. letter .. ";" }))
            table.insert(nodes, t({ "", "if (flag" .. prev .. ")" }))
            table.insert(nodes, t({ "", "{" }))
            table.insert(nodes, t({ "", "  flag" .. letter .. " = true;" }))
            table.insert(nodes, t({ "", "}" }))
            table.insert(nodes, t({ "", "else" }))
            table.insert(nodes, t({ "", "{" }))
            table.insert(nodes, t({ "", "  flag" .. letter .. " = false;" }))
            table.insert(nodes, t({ "", "}" }))
        end
        table.insert(nodes, t({ "", "if (flagZ)" }))
        table.insert(nodes, t({ "", "{" }))
        table.insert(nodes, t({ "", '  cout << "Yes" << "\\n";' }))
        table.insert(nodes, t({ "", "}" }))
        table.insert(nodes, t({ "", "else" }))
        table.insert(nodes, t({ "", "{" }))
        table.insert(nodes, t({ "", '  cout << "No" << "\\n";' }))
        table.insert(nodes, t({ "", "}" }))
        return nodes
    end)()),
    -- flagA=(cond)→flagB=flagA&&(cond)→...→flagZ、最後にYes/No出力
    s("flagflag3", (function()
        local nodes = {}
        local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        table.insert(nodes, t("bool flagA = ("))
        table.insert(nodes, i(1))
        table.insert(nodes, t(");"))
        for idx = 2, #letters do
            local letter = letters:sub(idx, idx)
            local prev = letters:sub(idx - 1, idx - 1)
            table.insert(nodes, t({ "", "bool flag" .. letter .. " = flag" .. prev .. ";" }))
        end
        table.insert(nodes, t({ "", 'cout << (flagZ ? "Yes" : "No") << "\\n";' }))
        return nodes
    end)()),
    -- mod付きべき（MOD系問題・フェルマー逆元用）
    s("powmod", {
        t({
            "long long powmod(long long base, long long exp, long long mod)",
            "{",
            "  long long result = 1;",
            "  base = (base % mod + mod) % mod;",
            "  while (exp > 0)",
            "  {",
            "    if (exp & 1) result = result * base % mod;",
            "    base = base * base % mod;",
            "    exp >>= 1;",
            "  }",
            "  return result;",
            "}",
        }),
    }),
    -- 素朴なnCr（MODなし）。答えがllに収まる範囲用、n≦61目安（62C31が上限付近）
    -- 掛けてから割る順序 res*(n-i)/(i+1) は必ず割り切れる（順序を変えると壊れる）
    s("cb", {
        t({
            "long long comb(long long n, long long r)",
            "{",
            "  if (r < 0 || r > n) return 0;",
            "  r = min(r, n - r);",
            "  long long res = 1;",
            "  for (long long i = 0; i < r; ++i) res = res * (n - i) / (i + 1);",
            "  return res;",
            "}",
        }),
    }),
    -- mod付きnCr（階乗・逆階乗テーブル、powmod内蔵で自己完結）
    -- main上で展開 → Comb cb(200005); → cb(n, r)。MOD変更は第2引数: Comb cb(n, 1000000007);
    s("comb", {
        t({
            "struct Comb",
            "{",
            "  vector<long long> fact, inv_fact;",
            "  long long mod;",
            "",
            "  Comb(int n, long long mod = 998244353) : fact(n + 1), inv_fact(n + 1), mod(mod)",
            "  {",
            "    fact[0] = 1;",
            "    for (int i = 1; i <= n; ++i) fact[i] = fact[i - 1] * i % mod;",
            "    // フェルマーの小定理で逆元: fact[n]^(mod-2)（powmod相当を内蔵）",
            "    long long base = fact[n], exp = mod - 2, result = 1;",
            "    while (exp > 0)",
            "    {",
            "      if (exp & 1) result = result * base % mod;",
            "      base = base * base % mod;",
            "      exp >>= 1;",
            "    }",
            "    inv_fact[n] = result;",
            "    for (int i = n; i >= 1; --i) inv_fact[i - 1] = inv_fact[i] * i % mod;",
            "  }",
            "",
            "  long long operator()(int n, int r)",
            "  {",
            "    if (r < 0 || r > n) return 0;",
            "    return fact[n] * inv_fact[r] % mod * inv_fact[n - r] % mod;",
            "  }",
            "};",
        }),
    }),
    -- Union-Find（DSU）。経路圧縮＋サイズ併合。main の中で uf<Tab> → UnionFind uf(n + 1); を挿入し、struct を int main の上に自動追加
    -- サイズの既定を n + 1 にしているのは、AtCoderのグラフ問題が頂点1..Nで与えられ、頂点番号をそのまま添字にできるため
    -- unite: 実際に併合したら true / 既に同一集合なら false。cnt=連結成分数、size(x)=xの属する成分サイズ
    s("uf", {
        f(function()
            vim.schedule(function()
                local bufnr = vim.api.nvim_get_current_buf()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local main_line = nil
                for i, line in ipairs(lines) do
                    if line:match("^int main") or line:match("^signed main") then
                        main_line = i - 1
                        break
                    end
                end
                if main_line then
                    vim.api.nvim_buf_set_lines(bufnr, main_line, main_line, false, {
                        "// 使い方（添字は0-indexed。デフォルトの uf(n + 1) は頂点1..nをそのまま添字に使う形）",
                        "//   UnionFind uf(n + 1);  頂点1..nの問題用。添字0は未使用のまま余る",
                        "//                         0-indexedなら uf(n)、グリッドなら uf(h * w)",
                        "//   uf.unite(x, y);       x,yを併合。実際に繋がったらtrue / 既に同じ集合ならfalse",
                        "//   uf.same(x, y);        同じ集合に属するか",
                        "//   uf.size(x);           xの属する集合の要素数",
                        "//   uf.cnt;               連結成分数。uf(n + 1) では未使用の頂点0が1成分として",
                        "//                         数え込まれるので、答えとして出すなら cnt - 1",
                        "//   uf.find(x);           xの代表元（同じ集合なら同じ値。直接使うことは少ない）",
                        "struct UnionFind",
                        "{",
                        "  vector<int> par, sz;",
                        "  int cnt; // 連結成分数",
                        "",
                        "  UnionFind(int n) : par(n), sz(n, 1), cnt(n)",
                        "  {",
                        "    iota(par.begin(), par.end(), 0);",
                        "  }",
                        "",
                        "  int find(int x)",
                        "  {",
                        "    return par[x] == x ? x : par[x] = find(par[x]);",
                        "  }",
                        "",
                        "  bool unite(int x, int y)",
                        "  {",
                        "    x = find(x);",
                        "    y = find(y);",
                        "    if (x == y) return false;",
                        "    if (sz[x] < sz[y]) swap(x, y);",
                        "    par[y] = x;",
                        "    sz[x] += sz[y];",
                        "    --cnt;",
                        "    return true;",
                        "  }",
                        "",
                        "  bool same(int x, int y) { return find(x) == find(y); }",
                        "  int size(int x) { return sz[find(x)]; }",
                        "};",
                        "",
                    })
                end
            end)
            return "UnionFind uf("
        end, {}),
        i(1, "n + 1"),
        t(");"),
    }),
    -- ACL互換の静的modint。main の上に本体と使い方を自動挿入
    s("mint", {
        f(function()
            vim.schedule(function()
                local bufnr = vim.api.nvim_get_current_buf()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local main_line = nil
                for i, line in ipairs(lines) do
                    if line:match("^int main") or line:match("^signed main") then
                        main_line = i - 1
                        break
                    end
                end
                if main_line then
                    vim.api.nvim_buf_set_lines(bufnr, main_line, main_line, false, {
                        '// 使い方: mint a = 3; cout << a.val() << "\\n"; // coutには.val()を渡す',
                        "// 割り算はmodが素数で、割る数がmodの倍数でないときだけ正しい",
                        "template <int m>",
                        "struct static_modint",
                        "{",
                        "  int v;",
                        "  static_modint() : v(0) {}",
                        "  template <class T> static_modint(T x)",
                        "  {",
                        "    long long y = x % m;",
                        "    if (y < 0) y += m;",
                        "    v = static_cast<int>(y);",
                        "  }",
                        "  int val() const { return v; }",
                        "  static_modint pow(long long n) const",
                        "  {",
                        "    static_modint a = *this, res = 1;",
                        "    while (n > 0)",
                        "    {",
                        "      if (n & 1) res *= a;",
                        "      a *= a;",
                        "      n >>= 1;",
                        "    }",
                        "    return res;",
                        "  }",
                        "  // フェルマーの小定理で逆元を計算（mは素数）",
                        "  static_modint inv() const { return pow(m - 2); }",
                        "  static_modint operator-() const { return static_modint(-v); }",
                        "  static_modint& operator+=(const static_modint& rhs) { v += rhs.v; if (v >= m) v -= m; return *this; }",
                        "  static_modint& operator-=(const static_modint& rhs) { v -= rhs.v; if (v < 0) v += m; return *this; }",
                        "  static_modint& operator*=(const static_modint& rhs) { v = static_cast<long long>(v) * rhs.v % m; return *this; }",
                        "  static_modint& operator/=(const static_modint& rhs) { return *this *= rhs.inv(); }",
                        "  friend static_modint operator+(static_modint lhs, const static_modint& rhs) { return lhs += rhs; }",
                        "  friend static_modint operator-(static_modint lhs, const static_modint& rhs) { return lhs -= rhs; }",
                        "  friend static_modint operator*(static_modint lhs, const static_modint& rhs) { return lhs *= rhs; }",
                        "  friend static_modint operator/(static_modint lhs, const static_modint& rhs) { return lhs /= rhs; }",
                        "  friend bool operator==(const static_modint& lhs, const static_modint& rhs) { return lhs.v == rhs.v; }",
                        "  friend bool operator!=(const static_modint& lhs, const static_modint& rhs) { return lhs.v != rhs.v; }",
                        "};",
                        "using modint998244353 = static_modint<998244353>;",
                        "using modint1000000007 = static_modint<1000000007>;",
                        "using mint = modint998244353;",
                        "",
                    })
                end
            end)
            return ""
        end, {}),
    }),
    -- ACL の segtree 宣言。展開位置に宣言、ファイル上部に #include <atcoder/segtree> と using namespace atcoder; を（無ければ）自動挿入。op / e の雛形と使い方コメントを int main の上に（無ければ）自動挿入
    s("seg", {
        f(function()
            vim.schedule(function()
                local bufnr = vim.api.nvim_get_current_buf()
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local last_include = nil
                local segtree_line = nil
                for i, line in ipairs(lines) do
                    if line:match("^#include") then
                        last_include = i - 1
                    end
                    if line:find("atcoder/segtree", 1, true) then
                        segtree_line = i - 1
                    end
                end
                if not segtree_line then
                    segtree_line = (last_include and last_include + 1) or 0
                    vim.api.nvim_buf_set_lines(bufnr, segtree_line, segtree_line, false, {
                        "#include <atcoder/segtree>",
                    })
                end
                lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local using_std = nil
                local has_using_atcoder = false
                for i, line in ipairs(lines) do
                    if line:find("using namespace std;", 1, true) then
                        using_std = i - 1
                    end
                    if line:find("using namespace atcoder;", 1, true) then
                        has_using_atcoder = true
                    end
                end
                if not has_using_atcoder then
                    local pos = (using_std or segtree_line) + 1
                    vim.api.nvim_buf_set_lines(bufnr, pos, pos, false, {
                        "using namespace atcoder;",
                    })
                end
                lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local has_op = false
                local main_line = nil
                for i, line in ipairs(lines) do
                    if line:find(" op(", 1, true) then
                        has_op = true
                    end
                    if not main_line and (line:match("^int main") or line:match("^signed main")) then
                        main_line = i - 1
                    end
                end
                if not has_op and main_line then
                    vim.api.nvim_buf_set_lines(bufnr, main_line, main_line, false, {
                        "// ACL segtree（0-indexed、区間は半開 [l, r)）",
                        "//   segtree<S, op, e> seg(n);  全要素 e() で初期化。seg(vector<S> v) で配列から作る",
                        "//   seg.set(p, x);             a[p] = x",
                        "//   seg.get(p);                a[p]",
                        "//   seg.prod(l, r);            op(a[l], ..., a[r - 1])。l == r なら e()",
                        "//   seg.all_prod();            全体",
                        "//   seg.max_right<f>(l);       f(prod(l, r)) が true になる最大の r（bool f(S) を定義、f(e()) は true）",
                        "//   seg.min_left<f>(r);        f(prod(l, r)) が true になる最小の l",
                        "// op: 2つの値をまとめる（結合法則を満たす）。e: op(a, e()) == a になる値",
                        "//   区間和 a + b / 0、区間最小 min(a, b) / LLONG_MAX、区間最大 max(a, b) / LLONG_MIN",
                        "long long op(long long a, long long b) { return a + b; }",
                        "long long e() { return 0; }",
                        "",
                    })
                end
            end)
            return "segtree<"
        end, {}),
        i(1, "long long"),
        t(", "),
        i(2, "op"),
        t(", "),
        i(3, "e"),
        t("> "),
        i(4, "seg"),
        t("("),
        i(5, "n"),
        t(");"),
    }),
    -- マルチテストケース（T個のケース）問題用の solve()+main 骨格
    -- テンプレ済みファイルでは main を消してから展開する想定（例: 3G → dG → sol<Tab>）
    -- 単一ケースで早期returnだけ使いたい時は cin >> t; を t = 1; に書き換える
    s("sol", {
        t({
            "void solve()",
            "{",
            "  ",
        }), i(1),
        t({
            "",
            "}",
            "",
            "int main()",
            "{",
            "  int t;",
            "  cin >> t;",
            "  while (t--) solve();",
            "}",
        }),
    }),
    -- vectorの昇順ソート
    s("sortv", {
        t("sort("), i(1, "a"), t(".begin(), "), rep(1), t(".end());"),
    }),
    -- vectorの降順ソート（rbegin/rendで逆順。greater<>()より短く型も問わない）
    s("sortvr", {
        t("sort("), i(1, "a"), t(".rbegin(), "), rep(1), t(".rend());"),
    }),
    -- vector定義のみ（入力ループ込みはcinv）
    s("vec", {
        t("vector<"), i(1, "int"), t("> "), i(2, "a"), t("("), i(3, "n"), t(");"),
    }),
    -- 2次元vector定義（グリッド問題用）。内側の要素型は外側の型に自動で揃う
    s("vec2", {
        t("vector<vector<"), i(1, "int"), t(">> "), i(2, "a"), t("("), i(3, "h"), t(", vector<"), rep(1), t(">("), i(4, "w"), t("));"),
    }),
})

-- cini/cinl/cins の変数リスト入力欄（タブストップ1）にいる間だけ、
-- 押しづらいカンマの代わりにスペースで区切れるようにする
local cin_var_list_snippets = { cini = true, cinl = true, cins = true, aai = true }
vim.keymap.set("i", "<Space>", function()
    local node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
    if node and node.pos == 1 then
        local ok, snip = pcall(function() return node:get_snippet() end)
        if ok and snip and cin_var_list_snippets[snip.trigger] then
            return ","
        end
    end
    return " "
end, { expr = true })
