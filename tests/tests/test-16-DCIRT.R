context('DCIRT')

test_that('DCIRT', {

    set.seed(1234)
    N <- 1000
    P <- 25

    # First, sample item parameters:
    a <- matrix(rlnorm(25, .2, .3))
    b <- matrix(rnorm(25, 0, 1.2))
    d <- -a*b # IRT -> FA (mirt)

    # Then, sample latent traits and simulate data:
    bimodal.woodslin <- c(rnorm(N*.6, mean = -.70, sd = .50), rnorm(N*.4, mean = 1.05, sd = .54))
    dat_bm <- simdata(a, d, itemtype = 'dich', Theta = as.matrix(bimodal.woodslin))

    mod <- mirt(dat_bm, 1, dentype = 'empiricalhist_Woods', verbose=FALSE,
                technical = list(zeroExtreme = TRUE))
    expect_equal(extract.mirt(mod, 'logLik'), -12709.16, tolerance=1e-4)
    fs1 <- fscores(mod)
    fs2 <- fscores(mod, use_dentype_estimate = TRUE)
    expect_equal(fs1[1:3], c(-1.5345966, -0.8099821, -1.2411356), tolerance=1e-4)
    expect_equal(fs2[1:3], c(-1.3326057, -0.9158906, -1.0891405), tolerance=1e-4)
    fs1 <- fscores(mod, method = 'EAPsum')
    fs2 <- fscores(mod, method = 'EAPsum', use_dentype_estimate = TRUE)
    expect_equal(fs1[1:3], c(-1.4499389, -0.8284078, -1.4499389), tolerance=1e-4)
    expect_equal(fs2[1:3], c(-1.2365365, -0.9185588, -1.2365365), tolerance=1e-4)
    resid <- residuals(mod, verbose=FALSE)
    resid2 <- residuals(mod, use_dentype_estimate=TRUE, verbose=FALSE)
    expect_equal(unname(resid[2:4,1]), c(3.4535477, -5.8701794, -0.1191689), tolerance=1e-4)
    expect_equal(unname(resid2[2:4,1]), c(2.1052352, -1.9251709, -0.1225053), tolerance=1e-4)

    pp <- plot(mod, type = 'empiricalhist')
    expect_is(pp, 'trellis')

    mod2 <- mirt(dat_bm, 1, dentype = 'EHW', verbose=FALSE)
    expect_equal(extract.mirt(mod2, 'logLik'), -12758.689, tolerance=1e-4)

    res_bm <- mirt(dat_bm, model = 1, dentype='Davidian-6', verbose=FALSE)
    expect_equal(extract.mirt(res_bm, 'logLik'), -12769.95, tolerance=1e-4)
    cfs <- coef(res_bm)$GroupPars
    expect_equal(as.vector(cfs), c(0,1,1.337812,0.1270967,-0.3512859,0.4509045,-0.6852344,-0.853839), tolerance=1e-4)

    cfs2 <- coef(res_bm, simplify=TRUE)
    expect_equal(c(0, 1, cfs2$Davidian_phis), as.vector(cfs))

    fs1 <- fscores(res_bm)
    fs2 <- fscores(res_bm, use_dentype_estimate = TRUE)
    expect_equal(fs1[1:3], c(-1.5116585, -0.8197455, -1.2697954), tolerance=1e-4)
    expect_equal(fs2[1:3], c(-1.3862425, -0.8486962, -1.2140458), tolerance=1e-4)
    fs1 <- fscores(res_bm, method = 'EAPsum')
    fs2 <- fscores(res_bm, method = 'EAPsum', use_dentype_estimate = TRUE)
    expect_equal(fs1[1:2], c(-1.442414, -0.832686), tolerance=1e-4)
    expect_equal(fs2[1:2], c(-1.3304990, -0.8606004), tolerance=1e-4)

    out <- itemfit(res_bm)
    out2 <- itemfit(res_bm, use_dentype_estimate=TRUE)
    expect_equal(out$S_X2[1:3], c(25.05182, 14.19290, 14.81142), tolerance=1e-4)
    expect_equal(out2$S_X2[1:3], c(25.45128, 14.03617, 13.87612), tolerance=1e-4)

    pp <- plot(res_bm, type = 'Davidian')
    expect_is(pp, 'trellis')
})

test_that('DCIRT Option Errors and Warnings', {

    set.seed(1234)
    N <- 1000
    P <- 25

    # First, sample item parameters:
    a <- matrix(rlnorm(25, .2, .3))
    b <- matrix(rnorm(25, 0, 1.2))
    d <- -a*b # IRT -> FA (mirt)

    # Then, sample latent traits and simulate data:
    bimodal.woodslin <- c(rnorm(N*.6, mean = -.70, sd = .50), rnorm(N*.4, mean = 1.05, sd = .54))
    dat_bm <- simdata(a, d, itemtype = 'dich', Theta = as.matrix(bimodal.woodslin))

    # Err from in dcurver:: ?
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-12', verbose=FALSE))

    # Estimation methods should fail:
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-6', method = "QMCEM", verbose=FALSE))
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-6', method = "MCEM", verbose=FALSE))
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-6', method = "MHRM", verbose=FALSE))
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-6', method = "SEM", verbose=FALSE))
    expect_error(mirt(dat_bm, model = 1, dentype='Davidian-6', method = "BL", verbose=FALSE))

})

# test_that('DCIRT Convergence', {
#
#     # An inconvergent data is needed.
#     set.seed(1234)
#     N <- 1000
#     P <- 25
#
#     # First, sample item parameters:
#     a <- matrix(rlnorm(25, .2, .3))
#     b <- matrix(rnorm(25, 0, 1.2))
#     d <- -a*b # IRT -> FA (mirt)
#
#     # Then, sample latent traits and simulate data:
#     bimodal.woodslin <- c(rnorm(N*.6, mean = -.70, sd = .50), rnorm(N*.4, mean = 1.05, sd = .54))
#     dat_bm <- simdata(a, d, itemtype = 'dich', Theta = as.matrix(bimodal.woodslin))
#
#     # Check inconvergent DCs
#
#     # Use alternative/random starting points
#
# })

test_that('DCIRT-MG', {
    set.seed(1234)
    N <- 1000
    P <- 25

    # First, sample item parameters:
    a <- matrix(rlnorm(25, .2, .3))
    b <- matrix(rnorm(25, 0, 1.2))
    d <- -a*b # IRT -> FA (mirt)

    # Then, sample latent traits and simulate data:
    bimodal.woodslin <- c(rnorm(N*.6, mean = -.70, sd = .50), rnorm(N*.4, mean = 1.05, sd = .54))
    dat_bm <- simdata(a, d, itemtype = 'dich', Theta = as.matrix(bimodal.woodslin))
    bimodal.woodslin2 <- c(rnorm(N*.6, mean = -.70, sd = .50), rnorm(N*.4, mean = 1.05, sd = .54))*.75 + .5
    dat_bm2 <- simdata(a, d, itemtype = 'dich', Theta = as.matrix(bimodal.woodslin2))
    dat <- rbind(dat_bm, dat_bm2)
    colnames(dat) <- paste0("Item", 1:ncol(dat))
    group <- rep(c('G1', 'G2'), each = nrow(dat_bm))

    mod_configural <- multipleGroup(dat, 1, group = group, dentype='Davidian-6',
                                    verbose = FALSE)
    # plot(mod_configural)
    expect_equal(extract.mirt(mod_configural, 'logLik'), -24206.476, tolerance=1e-4)
    cfs <- coef(mod_configural)$G2$GroupPars
    expect_equal(as.vector(cfs), c(0,1,1.387865,0.1158186,-0.3167727,0.4598686,-0.8611791,-0.6635325), tolerance=1e-4)

    cfs2 <- coef(mod_configural, simplify=TRUE)
    expect_equal(c(0, 1, cfs2$G2$Davidian_phis), as.vector(cfs))

    fs1 <- fscores(mod_configural)
    fs2 <- fscores(mod_configural, use_dentype_estimate = TRUE)
    expect_equal(fs1[1:3], c(-1.5094539, -0.8180814, -1.2677870), tolerance=1e-4)
    expect_equal(fs2[1:3], c(-1.3842002, -0.8462374, -1.2117934), tolerance=1e-4)
    fs1 <- fscores(mod_configural, method = 'EAPsum')
    fs2 <- fscores(mod_configural, method = 'EAPsum', use_dentype_estimate = TRUE)
    expect_equal(fs1[1:2], c(-1.4403539, -0.8310172), tolerance=1e-4)
    expect_equal(fs2[1:2], c(-1.3284337, -0.8581034), tolerance=1e-4)

    out <- itemfit(mod_configural)
    out2 <- itemfit(mod_configural, use_dentype_estimate=TRUE)
    expect_equal(out$G2$S_X2[1:3], c(14.92518, 17.84197, 10.97212), tolerance=1e-4)
    expect_equal(out2$G2$S_X2[1:3], c(14.93878, 17.17929, 10.92357), tolerance=1e-4)

    pp <- plot(mod_configural, type = 'Davidian')
    expect_is(pp, 'trellis')

    # not equated
    mod_scalar0 <- multipleGroup(dat, 1, group = group, verbose=FALSE, dentype='Davidian-6',
                                invariance=colnames(dat)[1:5])
    # coef(mod_scalar0, simplify=TRUE)
    expect_equal(extract.mirt(mod_scalar0, 'logLik'), -24277.35, tolerance=1e-4)
    expect_equal(extract.mirt(mod_scalar0, 'df'), 33554329)
    # plot(mod_scalar0)
    pp <- plot(mod_scalar0, type = 'Davidian')
    expect_is(pp, 'trellis')

    # equated
    expect_error(multipleGroup(dat, 1, group = group, verbose=FALSE, dentype='Davidian-6',
                                 invariance=c(colnames(dat)[1:10], 'free_var','free_means')))
    # plot(mod_scalar)
    # expect_equal(extract.mirt(mod_scalar, 'df'), 33554337)
    # expect_equal(extract.mirt(mod_scalar, 'logLik'), -48247.41, tolerance=1e-4)
    # expect_equal(M2(mod_scalar)$M2, 600.9787, tolerance=1e-4)
    # cfs <- as.vector(unname(coef(mod_scalar)$G2$GroupPars))
    # expect_equal(cfs, c(0.4745419,0.6083134,1.200818,2.058516,2.109649,3.667984,-0.6940906,0.7198784), tolerance=1e-4)
    #
    # pp <- plot(mod_scalar, type = 'Davidian')
    # expect_is(pp, 'trellis')

    # equated EHW
    mod_scalarEHW <- multipleGroup(dat, 1, group = group, verbose=FALSE, dentype='EHW',
                                invariance=c(colnames(dat)[1:10], 'free_var','free_means'))
    # plot(mod_scalarEHW)
    expect_equal(extract.mirt(mod_scalarEHW, 'df'), 33554113)
    expect_equal(extract.mirt(mod_scalarEHW, 'logLik'), -24199.93, tolerance=1e-4)
    cfs <- as.vector(unname(coef(mod_scalarEHW)$G2$GroupPars))
    expect_equal(cfs, c(0.4228267, 0.5387933), tolerance=1e-4)

    pp <- plot(mod_scalarEHW, type = 'empiricalhist')
    expect_is(pp, 'trellis')


})


